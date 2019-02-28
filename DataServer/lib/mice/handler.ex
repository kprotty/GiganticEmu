defmodule DS.Mice.Handler do
  require Logger
  alias DS.Mice.Client, as: Self

  def handle_command(self, "player.getservertime", _) do
    {:ok, date} = Calendar.DateTime.now_utc |> Calendar.Strftime.strftime("%Y.%m.%d-%H:%M:%S")
    {self, [%{datetime: date}]}
  end

  def handle_command(self, command, payload) do
    Logger.info "Unhandled command \"#{command}\" #{inspect(payload)}"
    {self, nil}
  end
end