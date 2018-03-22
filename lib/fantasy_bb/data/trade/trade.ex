defmodule FantasyBb.Data.Trade do
  alias FantasyBb.Data.Trade.Queries

  defdelegate for_scoring(season_id), to: Queries
end
