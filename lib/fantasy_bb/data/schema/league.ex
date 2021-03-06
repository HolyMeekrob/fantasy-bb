defmodule FantasyBb.Data.Schema.League do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      assoc_constraint: 2,
      foreign_key_constraint: 2
    ]

  schema "league" do
    field(:name, :string)
    belongs_to(:season, FantasyBb.Data.Schema.Season)
    belongs_to(:commissioner, FantasyBb.Data.Schema.User)

    timestamps()

    has_many(:teams, FantasyBb.Data.Schema.Team)
    has_many(:rules, FantasyBb.Data.Schema.Rule)
  end

  def changeset(league, params \\ %{}) do
    league
    |> cast(params, [:name, :season_id, :commissioner_id])
    |> validate_required([:name, :season_id, :commissioner_id])
    |> assoc_constraint(:season)
    |> assoc_constraint(:commissioner)
    |> foreign_key_constraint(:commissioner_id)
  end
end
