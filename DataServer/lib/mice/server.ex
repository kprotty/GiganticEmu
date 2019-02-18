defmodule DS.Mice.Server do
  use GenServer
  alias __MODULE__

  defstruct(
    port: 12000,
    clients: MapSet.new(),
    parties: MapSet.new(),
    match_parties: MapSet.new(),
    ck: "SALSA_CLIENT_KEY",
    sk: "SALSA_SERVER_KEY"
  )

  def child_spec(options), do: %{
    type: :worker,
    id: __MODULE__,
    shutdown: 5000,
    restart: :permanent,
    start: {__MODULE__, :start_link, [options]}
  }

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end
  
  def init([port: port, salsa_ck: ck, salsa_sk: sk]) do
    self = %Server{ck: ck, sk: sk, port: port}
    options = [port: self.port]
    {:ok, _} = :ranch.start_listener(DS.Mice.Tcp, :ranch_tcp, options, DS.Mice.Client, [])
    {:ok, self}
  end

  def add_client(client), do:
    GenServer.cast(__MODULE__, {:new_client, client})
  def drop_client(client), do:
    GenServer.cast(__MODULE__, {:drop_client, client})

  def handle_cast({:new_client, client}, self), do:
    {:noreply, %{self | clients: MapSet.put(self.clients, client) }}
  def handle_cast({:drop_client, client}, self), do:
    {:noreply, %{self | clients: MapSet.delete(self.clients, client) }}

end