defmodule ApiWeb.WorkingTimeController do
  use ApiWeb, :controller

  import Ecto.Query, only: [from: 2]
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

  def indexWorkingTime(conn, %{"userID" => user, "start" => start, "end" => endInput}) do
    query = from workingTime in WorkingTime, where: workingTime.start == ^start and workingTime.end == ^endInput and workingTime.user_id == ^user
    query
      |> render(conn, "index.json", query: Repo.all())
  end

  def create(conn, %{"working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", working_time_path(conn, :show, working_time))
      |> render("show.json", working_time: working_time)
    end
  end

  def createWorkingTimeUser(conn, %{"userID" => user, "start" => start, "end" => endInput}) do
    with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time([user: user, start: start, end: endInput]) do
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
