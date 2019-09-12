defmodule Api.Auth.Clocking do
  use Ecto.Schema
  import Ecto.Changeset


  schema "clocks" do
    field :status, :boolean, default: false
    field :time, :naive_datetime
    belongs_to :user, Api.Auth.User, foreign_key: :user_a

    timestamps()
  end

  @doc false
  def changeset(clocking, attrs) do
    clocking
    |> cast(attrs, [:time, :status, :user_a])
    |> validate_required([:time, :status])
  end
end
