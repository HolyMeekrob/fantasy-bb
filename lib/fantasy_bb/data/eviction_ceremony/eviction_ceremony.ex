defmodule FantasyBb.Data.EvictionCeremony do
  alias FantasyBb.Data.EvictionCeremony.Queries

  defdelegate for_scoring(season_id), to: Queries
end
