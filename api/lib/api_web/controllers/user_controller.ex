defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  
  require Logger

  alias Api.Auth
  alias Api.Auth.User

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with  {:ok, %User{} = user} <- Auth.create_user(user_params) do
      # Create a claims with the data from the back
      claims = %{"id" => user.id, "role" => user.role_id}
      # Encode and get the token 
      # token shape : {:ok, token, claims}
      # token is a tuple in Elixir
      token = Api.Token.encode_and_sign(claims)
      conn
      |> render("jwt.json", jwt: elem(token, 1))
      #|> put_status(:created)
      #|> put_resp_header("location", user_path(conn, :show, user))
      #|> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def showUserById(conn, %{"userID" => userID}) do
    user = Auth.get_user!(userID)
    render(conn, "show.json", user: user)
  end

  def showUser(conn, params) do	
    # If the params are empty, get the index
    if Map.equal?(%{}, params) do 
      index(conn, params)
    else 
      # Find in the database :
      # parameter 1 : name schema
      # paramater 2 : parameters (attributes)
      case Api.Repo.get_by(User, [email: Map.get(params, "email"), username: Map.get(params, "username")]) do
		  	nil -> {:error, :not_found} # Null : not found 
		    user -> {:ok, user} # Found : give the user 
		    render(conn, "user.json", user: user) # Show in json, the user
		  end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    with {:ok, %User{} = user} <- Auth.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    with {:ok, %User{}} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  # When sign in
  def sign_in(conn, %{"email" => email, "password" => password}) do
    # Search in the database
    case Auth.token_sign_in(email, password) do 
      # Found something
      {:ok, token, _claims} -> 
        conn 
        |> render("jwt.json", jwt: token)
      # Not found
      _ ->
        {:error, :unauthorized}
    end
  end
end
