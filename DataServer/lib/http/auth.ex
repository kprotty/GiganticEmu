defmodule DS.Http.Auth do
  import Plug.Conn

  def create(conn) do
    {status, data} = case conn.params do
      %{"arc_token" => arc_token, "v" => _version} -> {200, %{
        result: "ok",
        username: "test@email.com",
        name: "ProttyNick",
        min_version: 16897,
        token: arc_token,
        auth: arc_token,
        host: "127.0.0.1",
        port: Application.get_env(:ds, :mice_port),
        accounts: "accmple",
        current_version: 16897,
        ck: Base.encode64("\x00\x00" <> Application.get_env(:ds, :salsa_ck)),
        sck:  Base.encode64("\x00\x00" <> Application.get_env(:ds, :salsa_sk)),
        xbox_preview: false,
        founders_pack: true,
        buddy_key: false,
        flags: "",
        mostash_verbosity_level: 0,
        voice_chat: %{
          baseurl: "http://127.0.01/voice.html",
          username: "sip:.username.@voice.sipServ.com",
          token: "sipToken",
        },
        announcements: %{
          message: "Some server message",
          status: "Some server status",
        },
        catalog: %{
          cdn_url: "http://127.0.0.1/cdn.html",
          sha256_digest: "04cd2302958566b0219c78a6066049933f5da07ec23634f986194ba6e7c9094e"
        }
      }}
      _ -> {401, %{}}
    end
    send_resp(conn, status, Jason.encode!(data))
  end

end