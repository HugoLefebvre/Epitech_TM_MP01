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

  scope "/", ApiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", MainWeb do
    pipe_through :api # Use the default browser stack

    get "/", PageController, :index
	resources "/users", UserController, except: [:new, :edit]
	resources "/workingtimes", WorkingTimeController, except: [:new, :edit]
	resources "/clocking", ClockingController, except: [:new, :edit, :index, :update, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApiWeb do
  #   pipe_through :api
  # end
end
