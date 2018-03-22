defmodule FantasyBb.Data.Event.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Event

  import Ecto.Query, only: [from: 2]

  def for_scoring(season_id) do
    from(
      event in Event,
      inner_join: eviction_ceremony in assoc(event, :eviction_ceremony),
      inner_join: week in assoc(eviction_ceremony, :week),
      where: week.season_id == ^season_id,
      preload: [eviction_ceremony: {eviction_ceremony, week: week}]
    )
    |> Repo.all()
  end
end
