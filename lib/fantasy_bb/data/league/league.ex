defmodule FantasyBb.Data.League do
  alias FantasyBb.Data.League.Commands
  alias FantasyBb.Data.League.Queries

  defdelegate create(league), to: Commands
  defdelegate query(), to: Queries
  defdelegate for_user(query, user_id), to: Queries
  defdelegate with_teams(query), to: Queries
  defdelegate with_commissioner(query), to: Queries
  defdelegate get_all(query), to: Queries
end
