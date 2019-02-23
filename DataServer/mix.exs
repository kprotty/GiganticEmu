defmodule DS.MixProject do
  use Mix.Project

  def project, do: [
    app: :ds,
    elixir: "~> 1.0",
    version: "0.1.0",
    deps: deps(),
    aliases: aliases(),
    build_embedded: Mix.env() == :prod,
    start_permanent: Mix.env() == :prod,
  ]

  def application, do: [
    extra_applications: [:logger, :ecto, :postgrex],
    mod: {DS.Application, []}
  ]

  defp aliases, do: [
    "db.setup": ["ecto.create", "ecto.migrate"],
    "db.reset": ["ecto.drop", "db.setup"],
  ]

  defp deps, do: [
    {:ecto, "~> 3.0"},
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"},
    {:jason, "~> 1.1"},
    {:ranch, "~> 1.7"},
    {:plug_cowboy, "~> 2.0"},
    {:bcrypt_elixir, "~> 2.0"},
  ]
end