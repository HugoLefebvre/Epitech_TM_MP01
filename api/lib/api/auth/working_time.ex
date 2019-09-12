defmodule Api.Auth.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset


  schema "workingtimes" do
    field :end, :naive_datetime
    field :start, :naive_datetime
    belongs_to :user, Api.Auth.User, foreign_key: :user_a

    timestamps()
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_a])
    |> validate_required([:start, :end])
  end
end
