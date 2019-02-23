use Mix.Config

config :ds,
  http_host: System.get_env("HTTP_HOST") || "127.0.0.1",
  http_port: System.get_env("HTTP_PORT") || 12000,
  mice_host: System.get_env("MICE_HOST") || "127.0.0.1",
  mice_port: System.get_env("MICE_PORT") || 13000,
  salsa_ck:  System.get_env("SALSA_CK")  || "aaaaaaaaaaaaaaaa",
  salsa_sck: System.get_env("SALSA_SCK") || "bbbbbbbbbbbbbbbb"

config :ds, DS.Database.Repo,
  database: "gigantic_dev",
  username: System.get_env("DB_USER") || "gigantic",
  password: System.get_env("DB_PASS") || "gigantic",
  hostname: System.get_env("DB_HOST") || "127.0.0.1",
  port:     System.get_env("DB_PORT") || 5432

config :ds, ecto_repos: [DS.Database.Repo]