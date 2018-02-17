defmodule FantasyBb.Schema.Season do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  schema "season" do
    field(:start, :date)
    field(:title, :string)

    timestamps()

    has_many(:leagues, FantasyBb.Schema.League)
    has_many(:houseguests, FantasyBb.Schema.Houseguest)
  end

  def changeset(season, params \\ %{}) do
    season
    |> cast(params, [:start, :title])
    |> validate_required([:start, :title])
  end
end
