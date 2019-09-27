defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  
  require Logger

  alias Api.Auth
  alias Api.Auth.User

  action_fallback ApiWeb.FallbackController

  # GET the list of all users
  # No parameters
  # Authorization : Bearer token
  # Only the admin can list all the users
  def index(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :  
        case String.equivalent?(currentUser.role.name, "admin") do 
          false -> {:error, :unauthorizedUser}
          true ->       
            users = Auth.list_users() # Get the list of user in the database
            render(conn, "index.json", %{users: users})
        end
    end
  end

  # POST create a user
  # @param : username
  # @param : role_id
  # @param : email
  # @param : password
  # Authorization : Bearer token
  # Only admin and manager can create user
  def create(conn, %{"user" => user_params}) do
    adminId = Api.Repo.get_by(Api.Auth.Role, [name: "admin"]) # Get the user id

    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :
        # Test : 
        # The user is an admin : OK
        # The user is a manager and create a user other than admin : OK
        # Else : ERROR
        case (String.equivalent?(currentUser.role.name, "admin") || 
              (String.equivalent?(currentUser.role.name, "manager") && user_params["role_id"] == adminId.id)) do   
          false -> {:error, :unauthorizedUser}
          true -> 
            with  {:ok, %User{} = user} <- Auth.create_user(user_params) do
              # Create a claims with the data from the back
              claims = %{"id" => user.id, "role" => user.role_id}      
              {code, token, claims} = encode({}, claims) # Create a token for the user
              render(conn, "jwt.json", jwt: token)
            end
        end
    end
  end

  # GET show a user detail
  # @param : id
  # Authorization : Bearer token
  # Only the owner of the account or the admin or the manager can show the detail 
  def show(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :
        case (String.equivalent?(currentUser.role.name, "admin") || 
              String.equivalent?(currentUser.role.name, "manager") || 
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true ->
            user = Auth.get_user!(id)
            render(conn, "show.json", %{user: user})
        end
    end
  end

  # GET show the user detail by his id (same of the function above but the customer want this route precisely)
  def showUserById(conn, %{"userID" => userID}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :    
        case (String.equivalent?(currentUser.role.name, "admin") || 
              String.equivalent?(currentUser.role.name, "manager") || 
              currentUser.id == userID) do
          false -> {:error, :unauthorizedUser}
          true -> 
            user = Auth.get_user!(userID) # Get the user in the database
            render(conn, "show.json", %{user: user})
        end
    end
  end

  # GET user by his email and username
  # @param : email
  # @param : username
  # Authorization : Bearer token
  # Only the admin and the manager can show the user
  def showUser(conn, params) do
    case Map.equal?(%{}, params) do 
      true -> index(conn, params) # If the params are empty, get the index
      false ->
        case decode(conn) do # Get the user connect with the token 
          nil -> {:error, :unauthorizedUser}
          currentUser -> # Otherwise :
            case (String.equivalent?(currentUser.role.name, "admin") || 
                  String.equivalent?(currentUser.role.name, "manager")) do
              false -> {:error, :unauthorizedUser}
              true -> 
                case Api.Repo.get_by(User, [email: Map.get(params, "email"), username: Map.get(params, "username")]) do
                  nil -> {:error, :not_found} # Null : not found 
                  user -> {:ok, user} # Found : give the user 
                  render(conn, "show.json", %{user: user}) # Show in json, the user
                end
            end
        end
    end
  end

  # PUT or PATCH update a user info
  # @param : id
  # @param : username
  # @param : email
  # @param : password
  # @param : role_id
  # Authorization : Bearer token
  # Only the owner of the account, the manager and the admin have access
  def update(conn, %{"id" => id, "user" => user_params}) do
    adminId = Api.Repo.get_by(Api.Auth.Role, [name: "admin"]) # Get the user id

    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :
        case (String.equivalent?(currentUser.role.name, "admin") || 
              String.equivalent?(currentUser.role.name, "manager") || 
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true -> 
            user = Auth.get_user!(id) # Get the user who will be update

            case (user_params["role_id"] == adminId.id && currentUser.role.id != adminId.id) do 
              true -> {:error, :unauthorizedUser} # Only the admin can give the role admin to a user
              false -> 
                case String.equivalent?(user.password_hash, user_params["password"]) do 
                  false -> # Change if the password is different
                    with {:ok, %User{} = user} <- Auth.update_user(user, user_params) do
                      render(conn, "show.json", %{user: user})
                    end
                  true -> # Do no change the password for the user
                    with {:ok, %User{} = user} <- Auth.update_user_without_password(user, user_params) do
                      render(conn, "show.json", %{user: user})
                    end
                end
            end
        end
    end
  end

  # DELETE a user
  # @param : id
  # Authorization : Bearer token
  def delete(conn, %{"id" => id}) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      currentUser -> # Otherwise :
        case (String.equivalent?(currentUser.role.name, "admin") || 
              String.equivalent?(currentUser.role.name, "manager") || 
              currentUser.id == id) do
          false -> {:error, :unauthorizedUser}
          true -> 
            user = Auth.get_user!(id)
            |> Api.Repo.preload(:role)
            # Check if the user have authorization to delete the user
            case ((String.equivalent?(user.role.name, "admin") && !String.equivalent?(currentUser.role.name, "admin")) ||
                  (String.equivalent?(user.role.name, "manager") && !String.equivalent?(currentUser.role.name, "admin") && currentUser.id != user.id) || 
                  (String.equivalent?(user.role.name, "employee") && String.equivalent?(currentUser.role.name, "employee") && currentUser.id != user.id)) do
              true -> {:error, :unauthorizedUser}
              false -> 
                with {:ok, %User{}} <- Auth.delete_user(user) do
                  render(conn, "show.json", user: currentUser)
                end
            end
        end
    end
  end

  # When sign in
  # @param : email 
  # @param : password
  def sign_in(conn, %{"email" => email, "password" => password}) do  
    case Auth.sign_in(email, password) do # Search user with his email and password
      nil -> {:error, :unauthorized} # No user found
      claims -> # Otherwise :
        {code, token, claims} = encode({}, claims) # Create token for the user
        render(conn, "sign_in.json", %{jwt: token, claims: claims}) # Return the token to the front
    end 
  end

  # When logout
  # Authorization : Bearer token
  def logout(conn, _params) do
    case decode(conn) do # Get the user connect with the token 
      nil -> {:error, :unauthorizedUser}
      user -> # Otherwise :
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