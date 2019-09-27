defmodule ApiWeb.TeamController do
  use ApiWeb, :controller

  require Logger

  alias Api.Auth
  alias Api.Auth.Team

  action_fallback ApiWeb.FallbackController

  # GET : /teams
  # Authorization: Bearer token
  # Privileges: admin, manager
  def index(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            teams = Auth.list_teams()
            render(conn, "index.json", teams: teams)
        end
    end
  end

  # POST : /teams
  # param name
  # Authorization: Bearer token
  # Privileges: admin, manager
  def create(conn, %{"team" => team_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            with {:ok, %Team{} = team} <- Auth.create_team(team_params) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", team_path(conn, :show, team))
              |> render("show.json", team: team)
            end
        end
    end
  end

  # GET : /teams/:id
  # Authorization: Bearer token
  # Privileges: admin, manager
  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            team = Auth.get_team!(id)
            render(conn, "show.json", team: team)
        end
    end
  end

  # POST : /teams/:id
  # param name
  # Authorization: Bearer token
  # Privileges: admin, manager
  def update(conn, %{"id" => id, "team" => team_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            team = Auth.get_team!(id)

            with {:ok, %Team{} = team} <- Auth.update_team(team, team_params) do
              render(conn, "show.json", team: team)
            end
        end
    end
  end

  # PATCH : teams/:id
  # @param user_ids Array of user id
  # Authorization: Bearer token
  # Privileges: admin, manager
  def updateMembers(conn, %{"id" => id, "user_ids" => user_ids}) do 
    case decode(conn) do # Get the user connect with the token
      nil -> {:error, :unauthorizedUser}
      currentUser -> 
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            team = Auth.get_team!(id) # Get the current team

            with {:ok, %Team{} = team} <- Auth.update_team_members(team, user_ids) do 
              render(conn, "show.json", team: team)
            end
        end
    end
  end

  # POST : /teams/:id
  # Authorization: Bearer token
  # Privileges: admin, manager
  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            team = Auth.get_team!(id)
            with {:ok, %Team{}} <- Auth.delete_team(team) do
              send_resp(conn, :no_content, "")
            end
        end
    end
  end

  # Get user connected with the token
  defp decode(conn) do 
    # Take the prefix from a string 
    take_prefix = fn full, prefix ->
      base = String.length(prefix)
      String.slice(full, base, String.length(full) - base)
    end

    case List.first(get_req_header(conn, "authorization")) do # Get the token in the header
      nil -> nil # Return null if there is no authorization
      bearer -> 
        token = take_prefix.(bearer,"Bearer ") # Get the token
        {code, claims} = Api.Token.verify_and_validate(token) # Get the claims
        if code == :ok do # If there is no problem
          user = Auth.get_user!(Map.get(claims, "id")) # Get the user
          |> Api.Repo.preload(:role) # Get the role
          # If there is a token and is match with the user
          if (user.c_xsrf_token != nil && String.equivalent?(Map.get(claims, "c-xsrf-token"), user.c_xsrf_token)) do
            user # Return the user
          else
            nil
          end
        else 
          nil
        end 
    end 
  end
end
