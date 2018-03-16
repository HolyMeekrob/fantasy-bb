defmodule FantasyBb.Data.Schema.DraftPick do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      assoc_constraint: 2
    ]

  schema "draft_pick" do
    belongs_to(:team, FantasyBb.Data.Schema.Team)
    belongs_to(:houseguest, FantasyBb.Data.Schema.Houseguest)
    field(:draft_order, :integer)

    timestamps(updated_at: false)
  end

  def changeset(draft_pick, params \\ %{}) do
    draft_pick
    |> cast(params, [:team_id, :houseguest_id, :draft_order])
    |> validate_required([:team_id, :draft_order])
    |> assoc_constraint(:team)
    |> assoc_constraint(:houseguest)
  end
end
