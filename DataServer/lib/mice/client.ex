defmodule DS.Mice.Client do
  use GenServer
  alias __MODULE__
  alias DS.Mice.{Salsa, Server}

  defstruct(
    socket: nil,
    transport: nil,
    salsa_in: nil,
    salsa_out: nil
  )

  @ck Application.get_env(:ds, :salsa_ck)
  @sck Application.get_env(:ds, :salsa_sk)

  def start_link(ref, socket, transport, _options), do:
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport}])}

  def init({ref, socket, transport}) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [active: true])
    :gen_server.enter_loop(__MODULE__, [], %Client{
      socket: socket,
      transport: transport
    })
  end

  def handle_info({:tcp_closed, _}, self) do
    Server.drop_client(self)
    {:stop, :normal, self}
  end

  def handle_info({:tcp_error, _, _reason}, self) do
    Server.drop_client(self)
    {:stop, :normal, self}
  end

  def handle_info({:tcp, _, data}, %Client{salsa_in: nil}=self) do
    self = authenticate(%{self |
      salsa_in: Salsa.new(@sck, 16),
      salsa_out: Salsa.new(@sck, 16)
    }, data)
    {:noreply, self}
  end

  defp authenticate(self, data) do

    data = String.slice(data, 1, byte_size(data))
    {_, data} = Salsa.new(@ck, 12) |> Salsa.decrypt(data)
    data = Jason.decode!(data)
    IO.inspect data, label: "Auth"

    self
  end

end