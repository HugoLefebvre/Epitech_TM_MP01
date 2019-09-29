defmodule ApiWeb.ClockingController do
  use ApiWeb, :controller
  require Logger

  import Ecto.Query

  alias Api.Auth
  alias Api.Auth.Clocking

  action_fallback ApiWeb.FallbackController

  # GET : /clocks
  # Authorization: Bearer Token
  # Privileges: admin, manager
  # Get all the clocks of the database
  def index(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager")) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            # Query : get all the clocks order by time desc
            query = from c in Clocking,
                    order_by: [desc: c.time],
                    limit: 50
            clocks = Api.Repo.all(query)
            render(conn, "index.json", clocks: clocks)
        end
    end
  end

  # GET : /clocks/:userID
  # Authorization: Bearer Token
  # Privileges: admin, manager, owner
  # Get the last inserted clock of the user
  def indexUserClock(conn, %{"userID" => userID}) do 
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(userID, Integer.to_string(currentUser.id)) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            # Query : get the last inserted clock
            query = from c in Clocking,
                    where: c.user_a == ^elem(Integer.parse(userID),0),
                    order_by: [desc: c.inserted_at],
                    limit: 1    
            
            # Get the result of the query
            result = Api.Repo.one(query)

            # If result is null, render [], else render a result
            if (result == nil) do 
              render(conn, "index.json", clocks: [])
            else
              render(conn, "index.json", clocks: [result])
            end
        end
    end
  end

  # POST : /clocks
  # @param time
  # @param status
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  # Create a clock
  def create(conn, %{"clocking" => clocking_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(clocking_params["user_a"], Integer.to_string(currentUser.id)) do 
          false -> {:error, :unauthorizedUser}
          true ->
            with {:ok, %Clocking{} = clocking} <- Auth.create_clocking(clocking_params) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", clocking_path(conn, :show, clocking))
              |> render("show.json", clocking: clocking)
            end
        end
    end
  end

  # POST : /clocks/:userID
  # @param time
  # @param status
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  # Create a clock for an user
  def createUserClock(conn, %{"userID" => userID, "clocking" => clocking_params}) do 
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        currentUser.id
        |> inspect()
        |> Logger.info()
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(userID, Integer.to_string(currentUser.id))) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            # Map merge : merge the clocking params and the userID
            with {:ok, %Clocking{} = clocking} <- Auth.create_clocking(Map.merge(clocking_params, %{"user_a" => userID})) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", clocking_path(conn, :show, clocking))
              |> render("show.json", clocking: clocking)
            end
        end
    end
  end

  # GET : /clocks/:id
  # Authorization: Bearer token 
  # Privileges: admin, manager, owner
  # Get the clock for a user
  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(id, Integer.to_string(currentUser.id))) do 
          false -> {:error, :unauthorizedUser}
          true ->
            clocking = Auth.get_clocking!(id)
            render(conn, "show.json", clocking: clocking)
        end
    end
  end
  
  # PUT or PATCH : /clocks/:id
  # @param time
  # @param status
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  # Update a clock
  def update(conn, %{"id" => id, "clocking" => clocking_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(id, Integer.to_string(currentUser.id))) do 
          false -> {:error, :unauthorizedUser}
          true ->
            clocking = Auth.get_clocking!(id)
            
            with {:ok, %Clocking{} = clocking} <- Auth.update_clocking(clocking, clocking_params) do
              render(conn, "show.json", clocking: clocking)
            end
        end
    end
  end

  # DELETE : /clocks/:id
  # @param time
  # @param status
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  # Delete a clock
  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              String.equivalent?(id, Integer.to_string(currentUser.id))) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            clocking = Auth.get_clocking!(id)
            with {:ok, %Clocking{}} <- Auth.delete_clocking(clocking) do
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