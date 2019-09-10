defmodule ApiWeb.ClockingController do
  use ApiWeb, :controller

  alias Api.Auth
  alias Api.Auth.Clocking

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    clocks = Auth.list_clocks()
    render(conn, "index.json", clocks: clocks)
  end

  def create(conn, %{"clocking" => clocking_params}) do
    with {:ok, %Clocking{} = clocking} <- Auth.create_clocking(clocking_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", clocking_path(conn, :show, clocking))
      |> render("show.json", clocking: clocking)
    end
  end

  def show(conn, %{"id" => id}) do
    clocking = Auth.get_clocking!(id)
    render(conn, "show.json", clocking: clocking)
  end

  def update(conn, %{"id" => id, "clocking" => clocking_params}) do
    clocking = Auth.get_clocking!(id)

    with {:ok, %Clocking{} = clocking} <- Auth.update_clocking(clocking, clocking_params) do
      render(conn, "show.json", clocking: clocking)
    end
  end

  def delete(conn, %{"id" => id}) do
    clocking = Auth.get_clocking!(id)
    with {:ok, %Clocking{}} <- Auth.delete_clocking(clocking) do
      send_resp(conn, :no_content, "")
    end
  end
end
