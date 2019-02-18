defmodule DS.Mice.Server do
  use GenServer
  alias __MODULE__

  defstruct(
    port: 12000,
    clients: MapSet.new(),
    parties: MapSet.new(),
    match_parties: MapSet.new(),
    ck: Application.get_env(:ds, :salsa_ck, nil),
    sk: Application.get_env(:ds, :salsa_sk, nil),
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
  
  def init(options=[port: port]) do
    {:ok, _} = :ranch.start_listener(DS.Mice.Tcp, :ranch_tcp, options, DS.Mice.Client, [])
    {:ok, %Server {port: port}}
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