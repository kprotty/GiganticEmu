defmodule DS.Http.Auth do
  import Plug.Conn
  alias DS.Database.{Repo, User}

  def create(conn) do
    try do
      %{"arc_token" => arc_token} = conn.params
      %User{}=user = Repo.get_by(User, token: arc_token)
      {conn, %{result: "ok"}}
        |> with_user_info(user)
        |> with_server_info()
        |> with_mice_info()
        |> send_json(200)
    rescue
      error -> 
        send_json({conn, %{}}, 401)
        raise error
    end
  end

  defp send_json({conn, data}, status_code), do:
    send_resp(conn, status_code, Jason.encode!(data))

  defp with_user_info({conn, data}, user) do
    {conn, Map.merge(data, %{
      auth: user.token,
      token: user.token,
      buddy_key: false,
      name: user.nickname,
      accounts: "accmple",
      xbox_preview: false,
      founders_pack: true,
      username: user.email,
    })}
  end

  defp with_mice_info({conn, data}) do
    {conn, Map.merge(data, %{
      host: Application.get_env(:ds, :mice_host),
      port: Application.get_env(:ds, :mice_port),
      ck: Base.encode64("\x00\x00" <> Application.get_env(:ds, :salsa_ck)),
      sck: Base.encode64("\x00\x00" <> Application.get_env(:ds, :salsa_sck)),
    })}
  end

  defp get_version(:error), do: 16897
  defp get_version({version, _}), do: version
  defp get_version(%Plug.Conn{params: params}), do: params
    |> Map.get("version", Integer.to_string(get_version(:error)))
    |> Integer.parse
    |> get_version

  defp with_server_info({conn, data}) do
    version = get_version(conn)
    {conn, Map.merge(data, %{
      flags: "",
      min_version: version,
      current_version: version,
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
    })}
  end
end