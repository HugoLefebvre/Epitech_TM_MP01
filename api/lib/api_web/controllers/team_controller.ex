defmodule ApiWeb.TeamController do
  use ApiWeb, :controller

  alias Api.Auth
  alias Api.Auth.Team

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    teams = Auth.list_teams()
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Auth.create_team(team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", team_path(conn, :show, team))
      |> render("show.json", team: team)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Auth.get_team!(id)
    render(conn, "show.json", team: team)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Auth.get_team!(id)

    with {:ok, %Team{} = team} <- Auth.update_team(team, team_params) do
      render(conn, "show.json", team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Auth.get_team!(id)
    with {:ok, %Team{}} <- Auth.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
  end
end
