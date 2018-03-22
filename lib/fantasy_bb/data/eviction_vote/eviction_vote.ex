defmodule FantasyBb.Data.EvictionVote do
  alias FantasyBb.Data.EvictionVote.Queries

  defdelegate for_scoring(season_id), to: Queries
end
