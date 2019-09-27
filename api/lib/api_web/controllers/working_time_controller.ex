defmodule ApiWeb.WorkingTimeController do
  use ApiWeb, :controller

  require Logger
  import Ecto.Query

  alias Api.Auth
  alias Api.Auth.WorkingTime

  action_fallback ApiWeb.FallbackController

  # GET : /workingtimes/:userID
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def userWorkingTime(conn, %{"userID" => userID}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == userID) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            # Get the user in the folder Api/Repo with the userID
            user = Api.Repo.get(Api.Auth.User, userID)
              # Get the clock value
              |> Api.Repo.preload(:workingTime)

            # Give the JSON. workingtimes is the name of the table in the migration
            # Get the workingTime in the user
            render(conn, "index.json", workingtimes: user.workingTime)
        end
    end
  end

  # GET : /workingtimes
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
            workingtimes = Auth.list_workingtimes()
            render(conn, "index.json", workingtimes: workingtimes)
        end
    end
  end

  # GET : /workingtimes/userID?start=...&end=....
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def indexWorkingTime(conn, %{"userID" => userID, "start" => start, "end" => endInput}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        # If start and end is not set up, display all working for the user
        if (start == "" or endInput == "" or start == nil or endInput == nil) do
          userWorkingTime(conn, %{"userID" => userID})
        else 
          case (String.equivalent?(currentUser.role.name, "admin") ||
                String.equivalent?(currentUser.role.name, "manager") ||
                currentUser.id == userID) do 
            false -> {:error, :unauthorizedUser}
            true -> 
              # Query : get the working time between two datetime for a user
              query = from w in WorkingTime,
                      where: w.user_a == ^elem(Integer.parse(userID),0) and
                             w.start >= ^start and w.end <= ^endInput,
                             order_by: w.start
              # Find in the database :
              # parameter 1 : name schema
              # parameter 2 : parameters (attributes)
              case Api.Repo.all(query) do
                [] -> {:error, :not_found}
                workingtimes -> {:ok, workingtimes}
                render(conn, "show.json", working_time: workingtimes)
              end
          end
        end
    end
  end

  # POST : /workingtimes
  # @param start
  # @param end 
  # @param user_a Id of the user
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def create(conn, %{"working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") || 
              String.equivalent?(currentUser.role.name, "manager") ||
              working_time_params["user_a"] == currentUser.id) do 
          false -> {:error, :unauthorizedUser}
          true -> 
            with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(working_time_params) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", working_time_path(conn, :show, working_time))
              |> render("show.json", working_time: working_time)
            end
        end
    end
  end

  # POST : /workingtimes/:userID
  # @param start
  # @param end
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def createWorkingTimeUser(conn, %{"userID" => userID, "working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == userID) do
          false -> {:error, :unauthorizedUser}
          true -> 
            with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(Map.merge(working_time_params, %{"user_a" => userID})) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", working_time_path(conn, :show, working_time))
              |> render("show.json", working_time: working_time)
            end
        end
    end
  end

  # GET : /workingtimes/:id 
  # Privileges: admin, manager, owner
  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true -> 
            working_time = Auth.get_working_time!(id)
            render(conn, "show.json", working_time: working_time)
        end
    end
  end

  # GET : /workingtimes/:userID/:workingtimeID
  # @param start
  # @param end
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def showWorkingTimeUser(conn, %{"userID" => userID, "workingtimeID" => workingtimeID}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == userID) do
          false -> {:error, :unauthorizedUser}
          true -> 
            # Find in the database :
            # parameter 1 : name schema
            # parameter 2 : parameters (attributes)
            case Api.Repo.get_by(WorkingTime, [id: workingtimeID, user_a: userID]) do 
              nil -> {:error, :not_found}
              workingtimes -> {:ok, workingtimes}
              render(conn, "show.json", working_time: workingtimes)
            end
        end
    end
  end

  # PATCH or PUT : /workingtimes/:id
  # @param start
  # @param end
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true -> 
            working_time = Auth.get_working_time!(id)

            with {:ok, %WorkingTime{} = working_time} <- Auth.update_working_time(working_time, working_time_params) do
              render(conn, "show.json", working_time: working_time)
            end
        end
    end
  end

  # DELETE : /workingtimes/:id
  # @param start
  # @param end
  # @param user_a User id
  # Authorization: Bearer token
  # Privileges: admin, manager, owner
  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        case (String.equivalent?(currentUser.role.name, "admin") ||
              String.equivalent?(currentUser.role.name, "manager") ||
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true -> 
            working_time = Auth.get_working_time!(id)
            with {:ok, %WorkingTime{}} <- Auth.delete_working_time(working_time) do
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
