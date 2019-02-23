defmodule DS.Database.Repo do
  use Ecto.Repo,
    otp_app: :ds,
    adapter: Ecto.Adapters.Postgres
end