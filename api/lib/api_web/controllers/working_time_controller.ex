defmodule ApiWeb.WorkingTimeController do
  use ApiWeb, :controller

  require Logger

  alias Api.Auth
  alias Api.Auth.WorkingTime

  action_fallback ApiWeb.FallbackController

  # GET : /workingtimes/:userID
  def userWorkingTime(conn, %{"userID" => userID}) do
    # Get the user in the folder Api/Repo with the userID
    user = Api.Repo.get(Api.Auth.User, userID)
      # Get the clock value
      |> Api.Repo.preload(:workingTime)

    # Give the JSON. workingtimes is the name of the table in the migration
    # Get the workingTime in the user
    render(conn, "index.json", workingtimes: user.workingTime)
  end

  def index(conn, _params) do
    workingtimes = Auth.list_workingtimes()
    render(conn, "index.json", workingtimes: workingtimes)
  end

  # GET : /workingtimes/userID?start=...&end=....
  def indexWorkingTime(conn, %{"userID" => userID, "start" => start, "end" => endInput}) do

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

  def create(conn, %{"working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", working_time_path(conn, :show, working_time))
      |> render("show.json", working_time: working_time)
    end
  end

  # POST : /workingtimes/:userID
  def createWorkingTimeUser(conn, %{"userID" => userID, "working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(Map.merge(working_time_params, %{"user_a" => userID})) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", working_time_path(conn, :show, working_time))
      |> render("show.json", working_time: working_time)
    end
  end

  def show(conn, %{"id" => id}) do
    working_time = Auth.get_working_time!(id)
    render(conn, "show.json", working_time: working_time)
  end

  # GET : /workingtimes/:userID/:workingtimeID
  def showWorkingTimeUser(conn, %{"userID" => userID, "workingtimeID" => workingtimeID}) do
    # Find in the database :
    # parameter 1 : name schema
    # parameter 2 : parameters (attributes)
    case Api.Repo.get_by(WorkingTime, [id: workingtimeID, user_a: userID]) do 
      nil -> {:error, :not_found}
      workingtimes -> {:ok, workingtimes}
      render(conn, "show.json", working_time: workingtimes)
    end
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    working_time = Auth.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <- Auth.update_working_time(working_time, working_time_params) do
      render(conn, "show.json", working_time: working_time)
    end
  end

  def delete(conn, %{"id" => id}) do
    working_time = Auth.get_working_time!(id)
    with {:ok, %WorkingTime{}} <- Auth.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end
end
