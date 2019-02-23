defmodule DS.Database.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :token, :string
    field :nickname, :string
    field :password, :string
  end
end