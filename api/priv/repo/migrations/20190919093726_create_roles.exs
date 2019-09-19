defmodule Api.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :user_id, references(:users)

      timestamps()
    end

  end
end
