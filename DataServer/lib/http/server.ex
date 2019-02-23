defmodule DS.Http.Server do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    json_decoder: Jason

  plug :match
  plug :dispatch

  post "/auth/0.0/arc/auth", do:
    DS.Http.Auth.create(conn)

  match _, do:
    send_resp(conn, 404, Jason.encode!%{})

  def child_spec() do
    port = Application.get_env(:ds, :http_port)
    Logger.debug "[DS.Http] Starting server on :#{port}"

    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: __MODULE__,
      options: [port: port]
    )
  end
end