defmodule FantasyBb.Data.Event do
  alias FantasyBb.Data.Event.Queries

  defdelegate for_scoring(season_id), to: Queries
end
