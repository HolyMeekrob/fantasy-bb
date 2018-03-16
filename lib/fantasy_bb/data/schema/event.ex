defmodule FantasyBb.Data.Schema.Event do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      assoc_constraint: 2
    ]

  schema "event" do
    belongs_to(:event_type, FantasyBb.Data.Schema.EventType)
    belongs_to(:houseguest, FantasyBb.Data.Schema.Houseguest)
    belongs_to(:eviction_ceremony, FantasyBb.Data.Schema.EvictionCeremony)
    field(:additional_info, :string)

    timestamps(updated_at: false)
  end

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, [:event_type_id, :houseguest_id, :eviction_ceremony_id, :additional_info])
    |> validate_required([:event_type_id, :eviction_ceremony_id])
    |> assoc_constraint(:event_type)
    |> assoc_constraint(:houseguest)
    |> assoc_constraint(:eviction_ceremony)
  end
end
