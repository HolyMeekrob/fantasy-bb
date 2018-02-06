defmodule FantasyBb.Schema.EventType do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 2
    ]

  schema "event_type" do
    field(:name, :string)

    timestamps()

    has_many(:rules, FantasyBb.Schema.Rule)
    has_many(:events, FantasyBb.Schema.Event)
  end

  def changeset(event_type, params \\ %{}) do
    event_type
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
