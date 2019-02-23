defmodule DS.Database.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :token, :string
      add :nickname, :string
      add :password, :string
    end
  end
end
