defmodule FantasyBb.Data.Season do
  alias FantasyBb.Data.Season.Commands
  alias FantasyBb.Data.Season.Queries

  defdelegate get(id), to: Queries
  defdelegate get_upcoming(), to: Queries
  defdelegate query(), to: Queries
  defdelegate with_players(query), to: Queries
  defdelegate create(season), to: Commands
  defdelegate update(id, changes), to: Commands
end
