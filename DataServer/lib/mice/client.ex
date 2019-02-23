defmodule DS.Mice.Client do
  use Bitwise
  use DS.Mice.TcpClient
  import String, only: [slice: 2]

  alias DS.Mice.{Player, Salsa}
  alias DS.Database.{Repo, User}

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

  # send the encrypted json data with the length BER-encoded prepended
  defp send_out(data, %Self{salsa_out: salsa_out}=self) do
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
      send_out(Player.auth_response(player), %{self |
        player: player,
        salsa_in: Salsa.new(@sck, 16),
        salsa_out: Salsa.new(@sck, 16)
      })
    else
      _ -> close(self, "User with token #{token} doesnt exist")
    end
  end

  defp receive_data(%Self{buffer: buffer}=self, data) do
    self
  end
end