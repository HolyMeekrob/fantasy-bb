defmodule FantasyBb.Data.Schema.Team do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 3,
      assoc_constraint: 2
    ]

  schema "team" do
    belongs_to(:league, FantasyBb.Data.Schema.League)
    belongs_to(:owner, FantasyBb.Data.Schema.User, foreign_key: :user_id)
    field(:name, :string)
    field(:logo, :string)

    timestamps()

    has_many(:draft_picks, FantasyBb.Data.Schema.DraftPick)
    has_many(:trades, FantasyBb.Data.Schema.Trade, foreign_key: :initiated_by_team_id)
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:league_id, :user_id, :name, :logo])
    |> validate_required([:league_id, :user_id, :name])
    |> unique_constraint(:user_id, name: :team_league_id_user_id_index)
    |> assoc_constraint(:league)
    |> assoc_constraint(:owner)
  end
end
