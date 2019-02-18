defmodule DS.Database.Repo do
  use Ecto.Repo,
    otp_app: :ds,
    adapter: Ecto.Adapters.Postgres
end

defmodule DS.Database.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :name, :string
    field :nick, :string
    field :token, :string
  end
end