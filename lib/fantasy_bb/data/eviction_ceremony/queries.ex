defmodule FantasyBb.Data.EvictionCeremony.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.EvictionCeremony

  import Ecto.Query, only: [from: 2]

  def for_scoring(season_id) do
    from(
      eviction_ceremony in EvictionCeremony,
      left_join: eviction_votes in assoc(eviction_ceremony, :eviction_votes),
      inner_join: week in assoc(eviction_ceremony, :week),
      left_join: voter in assoc(eviction_votes, :voter),
      left_join: candidate in assoc(eviction_votes, :candidate),
      where: week.season_id == ^season_id,
      preload: [
        eviction_votes: {eviction_votes, voter: voter, candidate: candidate},
        week: week
      ]
    )
    |> Repo.all()
  end
end
