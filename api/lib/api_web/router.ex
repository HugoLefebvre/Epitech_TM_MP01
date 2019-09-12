defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, origin: "http://localhost:8080"
    plug :accepts, ["json"]
  end

  scope "/", ApiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", ApiWeb do
    pipe_through :api # Use the default browser stack

    get "/", PageController, :index
  end

	scope "/api/users", ApiWeb do
		pipe_through :api

    # Endpoint : http://localhost:4000/api/users?email=XXX&username=YYY
    # See showUser in user_controller
		get("/", UserController, :showUser)
		get "/:userID", UserController, :show
		resources "/", UserController, except: [:new, :edit]
	end

	scope "/api/workingtimes", ApiWeb do
		pipe_through :api

	#	get "/:userID", WorkingTimeController, :userWorkingTime
		get "/:userID", WorkingTimeController, :indexWorkingTime
		get "/:userID/:workingtimeID", WorkingTimeController, :showWorkingTimeUser
		post "/:userID", WorkingTimeController, :createWorkingTimeUser
		put "/:id", WorkingTimeController, :update
    delete "/:id", WorkingTimeController, :delete
    resources "/", WorkingTimeController, only: [:index, :show]
	end

	scope "/api/clocks", ApiWeb do
		pipe_through :api

    get "/:userID", ClockingController, :indexUserClock
    post "/:userID", ClockingController, :createUserClock
    resources "/", ClockingController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApiWeb do
  #   pipe_through :api
  # end
end
