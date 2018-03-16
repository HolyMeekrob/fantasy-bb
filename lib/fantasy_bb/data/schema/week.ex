defmodule FantasyBb.Data.Schema.Week do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 3,
      assoc_constraint: 2
    ]

  schema "week" do
    belongs_to(:season, FantasyBb.Data.Schema.Season)
    field(:week_number, :integer)

    timestamps(updated_at: false)

    has_many(:eviction_ceremonies, FantasyBb.Data.Schema.EvictionCeremony)
  end

  def changeset(week, params \\ %{}) do
    week
    |> cast(params, [:season_id, :week_number])
    |> validate_required([:season_id, :week_number])
    |> unique_constraint(:season_id, name: :week_season_id_week_number_index)
    |> assoc_constraint(:season)
  end
end
