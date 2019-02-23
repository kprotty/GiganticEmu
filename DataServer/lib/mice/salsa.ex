defmodule DS.Mice.Salsa do
  use Bitwise
  alias __MODULE__
  import String, only: [slice: 2]

  defstruct(
    rounds: 0,
    matrix: {}
  )

  def new(key, rounds) do
    [k1, k2, k3, k4 | _] = for <<k::little-32 <- key>>, do: k
    [c1, c2, c3, c4] = [0x61707865, 0x3120646e, 0x79622d36, 0x6b206574]
    %Salsa{
      rounds: rounds,
      matrix: {
        c1, k1, k2, k3,
        k4, c2, 0 , 0 ,
        0 , 0 , c3, k1,
        k2, k3, k4, c4,
      }
    }
  end

  # encrypt and decrypt have the same interface
  def decrypt(self, input), do: encrypt(self, input, [])
  def encrypt(self, input), do: encrypt(self, input, [])
  def encrypt(self, input, output) do
    stream = salsa_block(self)
    self = update_matrix(self)
    case stream_xor(stream, input) do
      data when byte_size(data) <= 64 ->
        {self, Enum.reverse([data | output])}
      data ->
        encrypt(self, slice(data, 64..-1), [data | output])
    end
  end

  # generate 64-byte encrypted salsa block from matrix state
  defp salsa_block(%Salsa{rounds: rounds, matrix: matrix}), do:
    Enum.reduce((0..div(rounds - 1, 2)), matrix, &gen_block/2)
      |> Tuple.to_list
      |> Stream.zip(Tuple.to_list(matrix))
      |> Stream.map(&add_to_u32/1)
      |> Enum.to_list
      |> IO.iodata_to_binary

  # TODO: figure out how client handles position overflow.
  defp update_matrix(%Salsa{matrix: matrix}=self) do
    matrix = put_elem(matrix, 8, elem(matrix, 8) + 1)
    case elem(matrix, 8) do
      0 -> %{self | matrix: put_elem(matrix, 9, elem(matrix, 9) + 1)}
      _ -> %{self | matrix: matrix}
    end
  end

  # uint32_t functions
  defp u32(number), do:
    number &&& 0xffffffff
  defp rotl(num, shift), do:
    u32((num <<< shift) ||| (num >>> (32 - shift)))
    
  # salsa functions
  defp add_to_u32({left, right}), do:
    <<u32(left + right) :: little-32>>
  defp mslice(left, right), do:
    binary_part(left, 0, min(byte_size(left), byte_size(right)))
  defp stream_xor(stream, input), do:
    mslice(stream, input) |> :crypto.exor(mslice(input, stream))
  defp merge(matrix, index, left, right, shift), do:
    put_elem(matrix, index,
      (elem(matrix, left) + elem(matrix, right))
        |> u32 
        |> rotl(shift) 
        |> bxor(elem(matrix, index)))

  # salsa rounds generation
  defp gen_block(_, matrix) do
    matrix = merge(matrix,  4,  0, 12,  7)
    matrix = merge(matrix,  8,  4,  0,  9)
    matrix = merge(matrix, 12,  8,  4, 13)
    matrix = merge(matrix,  0, 12,  8, 18)
    matrix = merge(matrix,  9,  5,  1,  7)
    matrix = merge(matrix, 13,  9,  5,  9)
    matrix = merge(matrix,  1, 13,  9, 13)
    matrix = merge(matrix,  5,  1, 13, 18)
    matrix = merge(matrix, 14, 10,  6,  7)
    matrix = merge(matrix,  2, 14, 10,  9)
    matrix = merge(matrix,  6,  2, 14, 13)
    matrix = merge(matrix, 10,  6,  2, 18)
    matrix = merge(matrix,  3, 15, 11,  7)
    matrix = merge(matrix,  7,  3, 15,  9)
    matrix = merge(matrix, 11,  7,  3, 13)
    matrix = merge(matrix, 15, 11,  7, 18)
    
    matrix = merge(matrix,  1,  0,  3,  7)
    matrix = merge(matrix,  2,  1,  0,  9)
    matrix = merge(matrix,  3,  2,  1, 13)
    matrix = merge(matrix,  0,  3,  2, 18)
    matrix = merge(matrix,  6,  5,  4,  7)
    matrix = merge(matrix,  7,  6,  5,  9)
    matrix = merge(matrix,  4,  7,  6, 13)
    matrix = merge(matrix,  5,  4,  7, 18)
    matrix = merge(matrix, 11, 10,  9,  7)
    matrix = merge(matrix,  8, 11, 10,  9)
    matrix = merge(matrix,  9,  8, 11, 13)
    matrix = merge(matrix, 10,  9,  8, 18)
    matrix = merge(matrix, 12, 15, 14,  7)
    matrix = merge(matrix, 13, 12, 15,  9)
    matrix = merge(matrix, 14, 13, 12, 13)
    matrix = merge(matrix, 15, 14, 13, 18)
    matrix
  end
end