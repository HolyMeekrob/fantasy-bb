defmodule FantasyBb.Data.Team do
  alias FantasyBb.Data.Team.Accessors
  alias FantasyBb.Data.Team.Queries

  defdelegate get(id), to: Queries
  defdelegate get(query, id), to: Queries
  defdelegate query(), to: Queries
  defdelegate for_overview(query), to: Queries

  defdelegate get_draft_picks(team), to: Accessors
end
