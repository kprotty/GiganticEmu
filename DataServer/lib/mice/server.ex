defmodule DS.Mice.Server do
  use DS.Mice.TcpServer

  @clients :mice_clients

  defp new() do
    options = [:named_table, :public, :set]
    :ets.new(@clients, options)
  end

end