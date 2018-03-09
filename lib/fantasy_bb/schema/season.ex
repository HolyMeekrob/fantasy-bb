defmodule FantasyBb.Schema.Season do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, put_assoc: 3]

  schema "season" do
    field(:start, :date)
    field(:title, :string)

    timestamps()

    has_many(:leagues, FantasyBb.Schema.League)

    many_to_many(
      :players,
      FantasyBb.Schema.Player,
      join_through: FantasyBb.Schema.Houseguest,
      on_replace: :delete
    )
  end

  def changeset(season, params \\ %{}) do
    season
    |> cast(params, [:start, :title])
    |> validate_required([:start, :title])
    |> put_assoc(:players, Map.get(params, :players, []))
  end
end
