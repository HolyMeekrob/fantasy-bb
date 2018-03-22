defmodule FantasyBb.Data.EvictionVote.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.EvictionVote

  import Ecto.Query, only: [from: 2]

  def for_scoring(season_id) do
    from(
      eviction_vote in EvictionVote,
      inner_join: eviction_ceremony in assoc(eviction_vote, :eviction_ceremony),
      inner_join: week in assoc(eviction_ceremony, :week),
      inner_join: voter in assoc(eviction_vote, :voter),
      inner_join: candidate in assoc(eviction_vote, :candidate),
      where: week.season_id == ^season_id,
      preload: [
        eviction_ceremony: {eviction_ceremony, week: week},
        voter: voter,
        candidate: candidate
      ]
    )
    |> Repo.all()
  end
end
