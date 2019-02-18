defmodule DS.Mice.Client do
  use GenServer, warn: false
  alias __MODULE__
  alias DS.Mice.Server

  defstruct(
    tcp: nil,
    socket: nil,
    initialized: false
  )

  def start_link(ref, socket, transport, _options) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(options), do: {:ok, options}
  def init(ref, socket, transport) do
    self = %Client{socket: socket, tcp: transport}
    IO.inspect socket, label: "New client"
    Server.add_client(self)

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [active: true])
    :gen_server.enter_loop(__MODULE__, [], self)
  end

  def handle_info({:tcp, _, data}, self) do
    IO.inspect data, label: "Data client"
    {:noreply, self}
  end

  def handle_info({:tcp_closed, _}, self) do
    IO.inspect self, label: "Drop client"
    Server.drop_client(self)
    {:stop, :normal, self}
  end

  def handle_info({:tcp_error, _, _reason}, self) do
    IO.inspect self, label: "Error client"
    Server.drop_client(self)
    {:stop, :normal, self}
  end

end