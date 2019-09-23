defmodule ApiWeb.ClockingController do
  use ApiWeb, :controller
  require Logger

  import Ecto.Query

  alias Api.Auth
  alias Api.Auth.Clocking

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    clocks = Auth.list_clocks()
    render(conn, "index.json", clocks: clocks)
  end

  # GET : /clocks/:userID
  def indexUserClock(conn, %{"userID" => userID}) do 

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