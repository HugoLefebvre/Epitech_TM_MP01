defmodule ApiWeb.ClockingController do
  use ApiWeb, :controller
  require Logger

  alias Api.Auth
  alias Api.Auth.Clocking

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    clocks = Auth.list_clocks()
    render(conn, "index.json", clocks: clocks)
  end

  # GET : /clocks/:userID
  def indexUserClock(conn, %{"userID" => userID}) do 
    # Get the user in the folder Api/Repo with the userID
    user = Api.Repo.get(Api.Auth.User, userID)
      # Get the clock value
      |> Api.Repo.preload(:clock)

    # Give the JSON. clocks is the name of the table in the migration
    # Get the clock in the user
    render(conn, "index.json", clocks: user.clock)
  end

  def create(conn, %{"clocking" => clocking_params}) do
    with {:ok, %Clocking{} = clocking} <- Auth.create_clocking(clocking_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", clocking_path(conn, :show, clocking))
      |> render("show.json", clocking: clocking)
    end
  end

  # POST : /clocks/userID
  def createUserClock(conn, %{"userID" => userID, "clocking" => clocking_params}) do 
    # Map merge : merge the clocking params and the userID
    with {:ok, %Clocking{} = clocking} <- Auth.create_clocking(Map.merge(clocking_params, %{"user_a" => userID})) do
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