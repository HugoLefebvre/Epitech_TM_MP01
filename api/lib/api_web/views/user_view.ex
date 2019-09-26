defmodule ApiWeb.UserView do
  use ApiWeb, :view
  alias ApiWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("indexCurrentUser.json",  %{users: users, currentUser: currentUser}) do
    %{
        data: render_many(users, UserView, "user.json"),
        currentUser: render_one(currentUser, UserView, "minimalUser.json")
      }
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("showCurrentUser.json", %{user: user, currentUser: currentUser}) do 
    %{
        data: render_one(user, UserView, "user.json"),
        currentUser: render_one(currentUser, UserView, "minimalUser.json")
      }
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      password: user.password_hash}
  end

  def render("minimalUser.json", %{user: user}) do 
    %{id: user.id,
      role: user.role_id}
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
