defmodule DS.Mice.Salsa do
  use Bitwise
  alias __MODULE__

  defstruct(
    rounds: 0,
    matrix: {}
  )

  def new(key, rounds) do
    [k1, k2, k3, k4] = for <<k::little-32 <- key>>, do: k
    [c1, c2, c3, c4] = [0x61707865, 0x3120646e, 0x79622d36, 0x6b206574]
    %Salsa{
      rounds: rounds, 
      matrix: {
        c1, k1, k2, k3,
        k4, c2, 0,  0,
        0,  0,  c3, k1,
        k2, k3, k4, c4,
      }  
    }
  end

  # interfaces for encrypting and decrypting
  def decrypt(self, input), do: encrypt(self, input)
  def encrypt(self, input) do
    chunks = for <<chunk::bytes-size(64) <- input>>, do: chunk
    encrypt_chunks({self, []}, chunks)
  end

  # iterate and encrypt 64-byte chunks
  defp encrypt_chunks({self, output}, []), do: {self, Enum.reverse(output)}
  defp encrypt_chunks({self, output}, [chunk | chunks]), do:
    gen_salsa_block(self)
      |> xor_bytes(self.matrix, chunk)
      |> update_matrix(output, self)
      |> encrypt_chunks(chunks)

  # matrix / stream / tuple getters & setters
  defp get(tuple, index), do: elem(tuple, index)
  defp get_with(tuple, index), do: {tuple, get(tuple, index)}
  defp update(tuple, index, updater), do:
    put_elem(tuple, index, updater.(get(tuple, index)))

  # TODO: figure out how the client handles position overflow
  defp update_matrix(input, output, %Salsa{matrix: matrix}=self) do
    matrix = case update(matrix, 8, &(&1 + 1)) |> get_with(8) do
      {matrix, 0} -> update(matrix, 9, &(&1 + 1))
      {matrix, _} -> matrix
    end
    {%{self | matrix: matrix}, [input | output]}
  end

  # uint32_t operations
  defp u32(x), do: 
    x &&& 0xffffffff
  defp rotl(x, shift), do:
    ((x <<< shift) ||| (x >>> (32 - shift))) |> u32
  defp merge(array, left, right, shift), do:
    (get(array, left) + get(array, right)) |> u32 |> rotl(shift)

  # xor bytes using salsa_block() as stream
  defp xor_bytes({value, index}, matrix), do:
    <<u32(get(matrix, index) + value) :: 32>>
  defp xor_bytes(block, matrix, chunk), do:
    Tuple.to_list(block)
      |> Stream.with_index
      |> Stream.map(&(xor_bytes(&1, matrix)))
      |> Enum.to_list
      |> :crypto.exor(chunk)

  defp gen_salsa_block(%Salsa{matrix: matrix, rounds: rounds}) do
    Enum.reduce(0..div(rounds, 2), matrix, fn _, block ->
      block = update(block,  4, &(&1 ^^^ merge(block,  0, 12,  7)))
      block = update(block,  8, &(&1 ^^^ merge(block,  4,  0,  9)))
      block = update(block, 12, &(&1 ^^^ merge(block,  8,  4, 13)))
      block = update(block,  0, &(&1 ^^^ merge(block, 12,  8, 18)))
      block = update(block,  9, &(&1 ^^^ merge(block,  5,  1,  7)))
      block = update(block, 13, &(&1 ^^^ merge(block,  9,  5,  9)))
      block = update(block,  1, &(&1 ^^^ merge(block, 13,  9, 13)))
      block = update(block,  5, &(&1 ^^^ merge(block,  1, 13, 18)))
      block = update(block, 14, &(&1 ^^^ merge(block, 10,  6,  7)))
      block = update(block,  2, &(&1 ^^^ merge(block, 14, 10,  9)))
      block = update(block,  6, &(&1 ^^^ merge(block,  2, 14, 13)))
      block = update(block, 10, &(&1 ^^^ merge(block,  6,  2, 18)))
      block = update(block,  3, &(&1 ^^^ merge(block, 15, 11,  7)))
      block = update(block,  7, &(&1 ^^^ merge(block,  3, 15,  9)))
      block = update(block, 11, &(&1 ^^^ merge(block,  7,  3, 13)))
      block = update(block, 15, &(&1 ^^^ merge(block, 11,  7, 18)))

      block = update(block,  1, &(&1 ^^^ merge(block,  0,  3,  7)))
      block = update(block,  2, &(&1 ^^^ merge(block,  1,  0,  9)))
      block = update(block,  3, &(&1 ^^^ merge(block,  2,  1, 13)))
      block = update(block,  0, &(&1 ^^^ merge(block,  3,  2, 18)))
      block = update(block,  6, &(&1 ^^^ merge(block,  5,  4,  7)))
      block = update(block,  7, &(&1 ^^^ merge(block,  6,  5,  9)))
      block = update(block,  4, &(&1 ^^^ merge(block,  7,  6, 13)))
      block = update(block,  5, &(&1 ^^^ merge(block,  4,  7, 18)))
      block = update(block, 11, &(&1 ^^^ merge(block, 10,  9,  7)))
      block = update(block,  8, &(&1 ^^^ merge(block, 11, 10,  9)))
      block = update(block,  9, &(&1 ^^^ merge(block,  8, 11, 13)))
      block = update(block, 10, &(&1 ^^^ merge(block,  9,  8, 18)))
      block = update(block, 12, &(&1 ^^^ merge(block, 15, 14,  7)))
      block = update(block, 13, &(&1 ^^^ merge(block, 12, 15,  9)))
      block = update(block, 14, &(&1 ^^^ merge(block, 13, 12, 13)))
      block = update(block, 15, &(&1 ^^^ merge(block, 14, 13, 18)))

      block
    end)
  end
end