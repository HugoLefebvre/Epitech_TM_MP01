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

      # Create a token for the user
      {code, token, claims} = encode({}, claims)

      conn
      |> render("jwt.json", jwt: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def showUserById(conn, %{"userID" => userID}) do
    currentUser = decode(conn) # Get the user connect with the token 

    case currentUser do
      nil -> {:error, :unauthorized}
      _ -> # Otherwise :        
        user = Auth.get_user!(userID) # Get the user in the database
        render(conn, "showCurrentUser.json", %{user: user, currentUser: currentUser})
    end
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
    claims = Auth.sign_in(email, password) # Search user with his email and password
    
    case claims do 
      nil -> {:error, :unauthorized} # No user found
      _ -> # Otherwise :
        {code, token, claims} = encode({}, claims) # Create token for the user
        render(conn, "jwt.json", jwt: token) # Return the token to the front
    end 
  end

  # When logout
  def logout(conn, _params) do
    user = decode(conn) # Get the user connect with the token 

    case user do 
      nil -> {:error, :unauthorized}
      _ -> # Otherwise :
        with {:ok, %User{} = user} <- Auth.update_token(user, %{"c_xsrf_token" => nil, "expire_time" => nil}) do
          render(conn, "show.json", user: user)
        end
    end
  end

  # param token : {}
  # param id : userId
  # param role : roleId
  # return : {code, token, claims}
  defp encode(token, %{"id" => id, "role" => role}) do
    xCsrfToken = get_csrf_token() # Generate a 50 characters x-csrf-token
    exp = Joken.current_time() * 60 * 60 * 24 * 30 # Generate a 30 days expire time
    
    # Update the user token
    user = Auth.get_user!(id)
    {code, test} = Auth.update_token(user, %{"c_xsrf_token" => xCsrfToken, "expire_time" => exp})

    # Create claims
    claims = %{"c-xsrf-token" => xCsrfToken, "id" => id, "role" => role, "exp" => exp}
    
    # Create a token
    token = Api.Token.encode_and_sign(claims)
  end

  # Get user connected with the token
  defp decode(conn) do 
    # Take the prefix from a string 
    take_prefix = fn full, prefix ->
      base = String.length(prefix)
      String.slice(full, base, String.length(full) - base)
    end

    # Get the token in the header
    bearer = List.first(get_req_header(conn, "authorization"))

    case bearer do 
      nil -> nil # Return null if there is no authorization
      _ -> 
        token = take_prefix.(bearer,"Bearer ") # Get the token
        {code, claims} = Api.Token.verify_and_validate(token) # Get the claims
        if code == :ok do # If there is no problem
          user = Auth.get_user!(Map.get(claims, "id")) # Get the user
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