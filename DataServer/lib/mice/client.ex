defmodule DS.Mice.Client do
  alias DS.Mice.{Player, Salsa}
  alias DS.Database.{Repo, User}

  use Bitwise
  use DS.Mice.TcpClient
  import String, only: [slice: 2]

  defstruct(
    socket: nil,
    player: nil,
    buffer: <<>>,
    salsa_in: nil,
    salsa_out: nil
  )

  @ck Application.get_env(:ds, :salsa_ck)
  @sck Application.get_env(:ds, :salsa_sck)

  defp new(socket) do
    %Self{socket: socket}
  end

  defp on_close(_self, _reason) do
    :ok # unbind
  end

  # equivalent to Ruby's Array.pack('w')
  defp pack_w(0, []), do: [0]
  defp pack_w(0, bytes), do: bytes
  defp pack_w(n, []), do:
    pack_w(n >>> 7, [n &&& 0x7f])
  defp pack_w(n, bytes), do:
    pack_w(n >>> 7, [((n &&& 0x7f) ||| 0x80) | bytes])

  # equivalent to Ruby's Array.unpack('w')
  defp unpack_w(<<>>, num), do: num
  defp unpack_w(<<b::1, bytes::binary>>, num), do:
    unpack_w(bytes, num <<< 7) ||| (b &&& 0x7f)

  # send the encrypted json data with the length BER-encoded prepended
  defp encode_data(data, %Self{salsa_out: salsa_out}=self) do
    {salsa_out, data} = Salsa.encrypt(salsa_out, Jason.encode!(data))
    length = IO.iodata_length(data) |> pack_w([])
    send_data(self, [length, data])
    %{self | salsa_out: salsa_out}
  end

  defp receive_data(%Self{player: nil}=self, data) do
    # extract token from json response: [token, ?]
    data = slice(data, 1..-1)
    data = Salsa.new(@ck, 12) |> Salsa.decrypt(data) |> elem(1)
    token = Jason.decode!(data) |> hd

    # find the user by the token, create a player and send auth_response
    with %User{}=user <- Repo.get_by(User, token: token) do
      player = Player.new(user)
      encode_data(Player.auth_response(player), %{self |
        player: player,
        salsa_in: Salsa.new(@sck, 16),
        salsa_out: Salsa.new(@sck, 16)
      })
    else
      _ -> close(self, "User with token #{token} doesnt exist")
    end
  end

  defp receive_data(%Self{buffer: buffer}=self, data) do
    {self, commands} = decode_data(%{self | buffer: <<>>}, buffer <> data, [])
    Enum.reduce(commands, self, fn [command, payload, id], self ->
      case DS.Mice.Handler.handle_command(self, command, payload) do
        {self, nil} -> self
        {self, data} -> encode_data([data, id], self)
      end
    end)
  end

  defp decode_data(self, <<first, _::binary>>=data, commands) when first >= 0x80, do:
    decode_data(self, unpack_w(binary_part(data, 0, 2), 0), data, 2, commands)
  defp decode_data(self, <<0xff, _::binary>>=data, commands), do:
    decode_data(self, unpack_w(binary_part(data, 0, 3), 0), data, 3, commands)
  defp decode_data(self, <<first, _::binary>>=data, commands), do:
    decode_data(self, first, data, 1, commands)
  defp decode_data(self, <<>>, commands), do:
    {self, Enum.reverse(commands)}
    
  defp decode_data(self, command_size, data, len_size, commands) do
    if command_size > byte_size(data) do
      {%{self | buffer: data}, Enum.reverse(commands)}
    else
      data = binary_part(data, len_size, byte_size(data) - len_size)
      <<command::bytes-size(command_size), data::binary>> = data
      {salsa_in, command} = Salsa.encrypt(self.salsa_in, command)
      commands = [Jason.decode!(command) | commands]
      decode_data(%{self | salsa_in: salsa_in}, data, commands)
    end
  end
end