defmodule Api.Auth.Clocking do
  use Ecto.Schema
  import Ecto.Changeset


  schema "clocks" do
    field :status, :boolean, default: false
    field :time, :naive_datetime
    field :user, :id

    timestamps()
  end

  @doc false
  def changeset(clocking, attrs) do
    clocking
    |> cast(attrs, [:time, :status])
    |> validate_required([:time, :status])
  end
end
