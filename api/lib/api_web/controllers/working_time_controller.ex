defmodule ApiWeb.WorkingTimeController do
  use ApiWeb, :controller

  require Logger

  alias Api.Auth
  alias Api.Auth.WorkingTime

  action_fallback ApiWeb.FallbackController

  # GET : /workingtimes/:userID
  def userWorkingTime(conn, %{"userID" => userID}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        # Get the user in the folder Api/Repo with the userID
        user = Api.Repo.get(Api.Auth.User, userID)
          # Get the clock value
          |> Api.Repo.preload(:workingTime)

        # Give the JSON. workingtimes is the name of the table in the migration
        # Get the workingTime in the user
        render(conn, "index.json", workingtimes: user.workingTime)
    end
  end

  def index(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        workingtimes = Auth.list_workingtimes()
        render(conn, "index.json", workingtimes: workingtimes)
    end
  end

  # GET : /workingtimes/userID?start=...&end=....
  def indexWorkingTime(conn, %{"userID" => userID, "start" => start, "end" => endInput}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        # If start and end is not set up, display all working for the user
        if (start == "" or endInput == "" or start == nil or endInput == nil) do
          userWorkingTime(conn, %{"userID" => userID})
        else 
          # Find in the database :
          # parameter 1 : name schema
          # parameter 2 : parameters (attributes)
          case Api.Repo.get_by(WorkingTime, [start: start, end: endInput, user_a: userID]) do
            nil -> {:error, :not_found}
            workingtimes -> {:ok, workingtimes}
            render(conn, "show.json", working_time: workingtimes)
          end
        end
    end
  end

  def create(conn, %{"working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(working_time_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", working_time_path(conn, :show, working_time))
          |> render("show.json", working_time: working_time)
        end
    end
  end

  # POST : /workingtimes/:userID
  def createWorkingTimeUser(conn, %{"userID" => userID, "working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(Map.merge(working_time_params, %{"user_a" => userID})) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", working_time_path(conn, :show, working_time))
          |> render("show.json", working_time: working_time)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        working_time = Auth.get_working_time!(id)
        render(conn, "show.json", working_time: working_time)
    end
  end

  # GET : /workingtimes/:userID/:workingtimeID
  def showWorkingTimeUser(conn, %{"userID" => userID, "workingtimeID" => workingtimeID}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
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

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        working_time = Auth.get_working_time!(id)

        with {:ok, %WorkingTime{} = working_time} <- Auth.update_working_time(working_time, working_time_params) do
          render(conn, "show.json", working_time: working_time)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser ->
        working_time = Auth.get_working_time!(id)
        with {:ok, %WorkingTime{}} <- Auth.delete_working_time(working_time) do
          send_resp(conn, :no_content, "")
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
