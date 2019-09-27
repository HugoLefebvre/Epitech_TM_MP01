defmodule ApiWeb.RoleController do
  use ApiWeb, :controller

  alias Api.Auth
  alias Api.Auth.Role

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            roles = Auth.list_roles()
            render(conn, "index.json", roles: roles)
        end
    end
  end

  def create(conn, %{"role" => role_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            with {:ok, %Role{} = role} <- Auth.create_role(role_params) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", role_path(conn, :show, role))
              |> render("show.json", role: role)
            end
        end
    end
  end

  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            role = Auth.get_role!(id)
            render(conn, "show.json", role: role)
        end
    end
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            role = Auth.get_role!(id)

            with {:ok, %Role{} = role} <- Auth.update_role(role, role_params) do
              render(conn, "show.json", role: role)
            end
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            role = Auth.get_role!(id)
            with {:ok, %Role{}} <- Auth.delete_role(role) do
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
