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
    plug :accepts, ["json"]
  end

#  scope "/", ApiWeb do
#    pipe_through :browser # Use the default browser stack

#    get "/", PageController, :index
#  end

#  scope "/api", ApiWeb do
#    pipe_through :api # Use the default browser stack

#    get "/", PageController, :index
#  end

	scope "/api/users", ApiWeb do
		pipe_through :api
	
		get("/", UserController, :show)
		get "/:userID", UserController, :index
		post "/", UserController, :create
		put "/:userID", UserController, :update
		delete "/:userID", UserController, :delete
	end

	scope "/api/workingtimes", ApiWeb do
		pipe_through :api

		get("/:userID", WorkingTimeController, :index)
		get "/:userID/:workingtimeID", WorkingTimeController, :show
		post "/:userID", WorkingTimeController, :create
		put "/:id", WorkingTimeController, :update
		delete "/:id", WorkingTimeController, :delete
	end

	scope "/api/clocks", ApiWeb do
		pipe_through :api
	
		get "/:userID", ClockingController, :show
		post "/:userID", ClockingController, :create
	end

  # Other scopes may use custom stacks.
  # scope "/api", ApiWeb do
  #   pipe_through :api
  # end
end
