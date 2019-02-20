defmodule DS.Mice.Server do
  use GenServer
  alias __MODULE__

  defstruct(
    clients: MapSet.new(),
    parties: MapSet.new(),
    match_parties: MapSet.new()
  )

  def start_link(options), do:
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  
  def init(options) do
    {:ok, _} = :ranch.start_listener(DS.Mice.Tcp, :ranch_tcp, options, DS.Mice.Client, [])
    {:ok, %Server{}}
  end

  def add_client(client), do:
    GenServer.cast(__MODULE__, {:client_new, client})
  def drop_client(client), do:
    GenServer.cast(__MODULE__, {:client_drop, client})

  def handle_cast({:client_new, client}, self), do:
    {:noreply, %{self | clients: self.clients |> MapSet.put(client)}}
  def handle_cast({:client_drop, client}, self), do:
    {:noreply, %{self | clients: self.clients |> MapSet.delete(client)}}

end