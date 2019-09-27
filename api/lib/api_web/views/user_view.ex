defmodule ApiWeb.UserView do
  use ApiWeb, :view
  alias ApiWeb.UserView

  require Logger

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      password: user.password_hash}
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end

  def render("sign_in.json", %{jwt: token, claims: claims}) do 
    %{
      jwt: token,
      idCurrentUser: claims["id"],
      roleCurrentUser: claims["role"]
    }
  end
end
