defmodule Api.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :username, :string
    has_many :workingTime, Api.Auth.WorkingTime, foreign_key: :user_a
    has_many :clock, Api.Auth.Clocking, foreign_key: :user_a

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
  end
end
