defmodule DS.Http.Router do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    json_decoder: Jason

  plug :match
  plug :dispatch

  post "/auth/0.0/arc/auth", do: DS.Http.Auth.create(conn)

  match _, do: send_resp(conn, 404, Jason.encode!(%{
    error: "This is not the route you're looking for"
  }))

end