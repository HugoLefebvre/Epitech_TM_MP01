defmodule Api.Auth.TeamsUsers do 
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams_users" do 
    belongs_to :team, Team
    belongs_to :user, User
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:team_id, :user_id])
    |> Ecto.Changeset.validate_required([:team_id, :user_id])
  end
end