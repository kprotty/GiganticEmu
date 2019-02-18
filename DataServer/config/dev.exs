use Mix.Config

config :ds,
  http_port: 12000,
  mice_port: 13000,
  salsa_ck: "aaaaaaaaaaaaaaaa",
  salsa_sk: "bbbbbbbbbbbbbbbb",
  ecto_repos: [DS.Database.Repo]

config :ds, DS.Database.Repo,
  database: "gigantic",
  username: "postgres",
  password: "3dsarcard",
  hostname: "localhost",
  port: "5432"