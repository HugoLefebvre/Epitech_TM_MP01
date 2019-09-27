defmodule Api.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :email, :string
    field :username, :string
    field :password_hash, :string
    field :c_xsrf_token, :string
    field :expire_time, :integer
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    has_many :workingTime, Api.Auth.WorkingTime, foreign_key: :user_a
    has_many :clock, Api.Auth.Clocking, foreign_key: :user_a
    belongs_to :role, Api.Auth.Role
    many_to_many :teams, Api.Auth.Team, join_through: "teams_users"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:role_id, :username, :email, :password, :password_confirmation, :c_xsrf_token, :expire_time])
    |> validate_required([:username, :email, :password, :role_id])
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}}
        ->
          put_change(changeset, :password_hash, hashpwsalt(pass))
      _ ->
          changeset
    end
  end

  @doc false
  def changeToken(user, attrs) do 
    user 
    |> cast(attrs, [:c_xsrf_token, :expire_time])
  end

  @doc false
  def changesetWithoutPassword(user, attrs) do
    user
    |> cast(attrs, [:role_id, :username, :email, :c_xsrf_token, :expire_time])
    |> validate_required([:username, :email, :role_id])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
