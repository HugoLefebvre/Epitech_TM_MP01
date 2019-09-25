defmodule Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :c_xsrf_token, :string, null: true
      add :expire_time, :bigint, null: true
      add :role_id, references(:roles)

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
