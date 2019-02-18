defmodule DS.MixProject do
  use Mix.Project

  def project, do: [
    app: :ds,
    deps: deps(),
    elixir: "~> 1.8",
    version: "0.0.1",
    start_embedded: Mix.env == :prod,
  ]

  def application, do: [
    extra_applications: [:logger, :plug_cowboy, :ecto, :ranch],
    mod: {DS.Application, []},
  ]

  defp deps, do: [
    {:ranch, "~> 1.7"},
    {:jason, "~> 1.1"},
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"},
    {:plug_cowboy, "~> 2.0"},
  ]

end