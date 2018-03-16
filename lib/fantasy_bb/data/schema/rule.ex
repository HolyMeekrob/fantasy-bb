defmodule FantasyBb.Data.Schema.Rule do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 3,
      assoc_constraint: 2
    ]

  schema "rule" do
    belongs_to(:league, FantasyBb.Data.Schema.League)
    belongs_to(:scorable, FantasyBb.Data.Schema.Scorable)
    field(:point_value, :integer)

    timestamps()
  end

  def changeset(rule, params \\ %{}) do
    rule
    |> cast(params, [:league_id, :scorable_id, :point_value])
    |> validate_required([:league_id, :scorable_id, :point_value])
    |> unique_constraint(:league_id, name: :rule_league_id_scorable_id_index)
    |> assoc_constraint(:league)
    |> assoc_constraint(:scorable)
  end
end
