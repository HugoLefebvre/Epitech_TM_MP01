defmodule Api.Auth.Team do
  use Ecto.Schema
  import Ecto.Changeset


  schema "teams" do
    field :name, :string
    many_to_many :users, Api.Auth.User, join_through: "teams_users"

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
