defmodule ApiWeb.WorkingTimeController do
  use ApiWeb, :controller

  alias Api.Auth
  alias Api.Auth.WorkingTime

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    workingtimes = Auth.list_workingtimes()
    render(conn, "index.json", workingtimes: workingtimes)
  end

  def create(conn, %{"working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <- Auth.create_working_time(working_time_params) do
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
