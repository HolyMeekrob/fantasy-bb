defmodule FantasyBb.Schema.Trade do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 2,
      foreign_key_constraint: 2
    ]

  schema "trade" do
    belongs_to(:initiated_by_team, FantasyBb.Schema.Team)
    belongs_to(:parent, FantasyBb.Schema.Trade)
    field(:message, :string)
    field(:is_approved, :boolean)

    timestamps()

    has_one(:child, FantasyBb.Schema.Trade, foreign_key: :parent_id)
    many_to_many(:houseguests, FantasyBb.Schema.Houseguest, join_through: "trade_piece")
  end

  def changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [:initiated_by_team_id, :parent_id, :message, :is_approved])
    |> validate_required([:initiated_by_team_id])
    |> unique_constraint(:parent)
    |> foreign_key_constraint(:initiated_by_team_id)
    |> foreign_key_constraint(:parent_id)
  end
end
