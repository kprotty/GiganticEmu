defmodule DS.Application do
  use Application
  require Logger

  @http_port Application.get_env(:ds, :http_port, 12000)
  @mice_port Application.get_env(:ds, :mice_port, 13000)

  defp mice_server, do: DS.Mice.Server.child_spec(port: @mice_port)
  defp http_server, do: Plug.Cowboy.child_spec(
    scheme: :http,
    plug: DS.Http.Router,
    options: [port: @http_port]
  )

  def start(_type, _args) do
    children = [
      http_server(),
      mice_server(),
      DS.Database.Repo,
    ]

    Logger.info("Starting http server on :#{@http_port}")
    Logger.info("Starting mice server on :#{@mice_port}")

    Supervisor.start_link(children, [
      name: DS.Application.Supervisor,
      strategy: :one_for_one
    ])
  end
end