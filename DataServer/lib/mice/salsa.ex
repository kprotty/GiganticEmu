defmodule DS.Mice.Salsa do
  use Bitwise 
  alias __MODULE__

  defstruct(
    rounds: 0,
    matrix: {},
  )

  def new(key, rounds) do
    [k1, k2, k3, k4] = for <<k::4 <- key>>, do: k
    [c1, c2, c3, c4] = [0x61707865, 0x3120646e, 0x79622d36, 0x6b206574]
    %Salsa{rounds: rounds, matrix: :array.fix(:array.from_list([
      c1, k1, k2, k3,
      k4, c2, 0,  0,
      0,  0,  c3, k1,
      k2, k3, k4, c4,
    ]))}
  end

  # looks like encrypt and decrypt to the same thing
  def decrypt(self, input), do: encrypt(self, input, [])
  def encrypt(self, input), do: encrypt(self, input, [])
  def encrypt(self, input, output) when byte_size(input) <= 64, do:
    Enum.reverse(output)
  def encrypt(self, <<input::bytes-size(64), rest::binary>>, output) do
    %Salsa{rounds: rounds, matrix: matrix} = self
    data = salsa_block(matrix, matrix, rounds) |> :crytpo.exor(input)
    encrypt(%{self | matrix: update(matrix)}, rest, [data | output])
  end

  # TODO: figure out how the client handles position overflow
  defp update(matrix) do
    matrix = set(matrix, 8, &(&1 + 1))
    case get(matrix, 8) do
      0 -> set(matrix, 9, &(&1 + 1))
      _ -> matrix
    end
  end

  # array alias getter/setter
  defp get(array, index), do: :array.get(array, index)
  defp set(array, index, reducer), do:
    :array.set(index, reducer.(get(array, index)), array)

  # uint32_t calculations
  defp u32(x), do: x &&& 0xffffffff
  defp rotl(x, shift), do:
    ((x <<< shift) ||| (x >>> (32 - shift))) |> u32
  defp merge(array, left, right, shift), do:
    (get(array, left) + get(array, right)) |> u32 |> rotl(shift)

  # generating salsa block as iodata
  defp salsa_block(matrix, stream, rounds) when rounds <= 0, do:
    :array.to_list(:array.map(&<<u32(get(matrix, &1) + &2)::32>>), stream)
  defp salsa_block(matrix, stream, rounds) do
    stream = set(stream,  4, &(&1 ^^^ merge(x,  0, 12,  7)))
    stream = set(stream,  8, &(&1 ^^^ merge(x,  4,  0,  9)))
    stream = set(stream, 12, &(&1 ^^^ merge(x,  8,  4, 13)))
    stream = set(stream,  0, &(&1 ^^^ merge(x, 12,  8, 18)))
    stream = set(stream,  9, &(&1 ^^^ merge(x,  5,  1,  7)))
    stream = set(stream, 13, &(&1 ^^^ merge(x,  9,  5,  9)))
    stream = set(stream,  1, &(&1 ^^^ merge(x, 13,  9, 13)))
    stream = set(stream,  5, &(&1 ^^^ merge(x,  1, 13, 18)))
    stream = set(stream, 14, &(&1 ^^^ merge(x, 10,  6,  7)))
    stream = set(stream,  2, &(&1 ^^^ merge(x, 14, 10,  9)))
    stream = set(stream,  6, &(&1 ^^^ merge(x,  2, 14, 13)))
    stream = set(stream, 10, &(&1 ^^^ merge(x,  6,  2, 18)))
    stream = set(stream,  3, &(&1 ^^^ merge(x, 15, 11,  7)))
    stream = set(stream,  7, &(&1 ^^^ merge(x,  3, 15,  9)))
    stream = set(stream, 11, &(&1 ^^^ merge(x,  7,  3, 13)))
    stream = set(stream, 15, &(&1 ^^^ merge(x, 11,  7, 18)))

    stream = set(stream,  1, &(&1 ^^^ merge(x,  0,  3,  7)))
    stream = set(stream,  2, &(&1 ^^^ merge(x,  1,  0,  9)))
    stream = set(stream,  3, &(&1 ^^^ merge(x,  2,  1, 13)))
    stream = set(stream,  0, &(&1 ^^^ merge(x,  3,  2, 18)))
    stream = set(stream,  6, &(&1 ^^^ merge(x,  5,  4,  7)))
    stream = set(stream,  7, &(&1 ^^^ merge(x,  6,  5,  9)))
    stream = set(stream,  4, &(&1 ^^^ merge(x,  7,  6, 13)))
    stream = set(stream,  5, &(&1 ^^^ merge(x,  4,  7, 18)))
    stream = set(stream, 11, &(&1 ^^^ merge(x, 10,  9,  7)))
    stream = set(stream,  8, &(&1 ^^^ merge(x, 11, 10,  9)))
    stream = set(stream,  9, &(&1 ^^^ merge(x,  8, 11, 13)))
    stream = set(stream, 10, &(&1 ^^^ merge(x,  9,  8, 18)))
    stream = set(stream, 12, &(&1 ^^^ merge(x, 15, 14,  7)))
    stream = set(stream, 13, &(&1 ^^^ merge(x, 12, 15,  9)))
    stream = set(stream, 14, &(&1 ^^^ merge(x, 13, 12, 13)))
    stream = set(stream, 15, &(&1 ^^^ merge(x, 14, 13, 18)))

    salsa_block(self, stream, rounds - 2)
  end

end