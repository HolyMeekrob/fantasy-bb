defmodule FantasyBb.Data.League do
  alias FantasyBb.Data.League.Commands
  alias FantasyBb.Data.League.Queries
  alias FantasyBb.Data.Schema.League

  defdelegate query(), to: Queries
  defdelegate for_user(query, user_id), to: Queries
  defdelegate with_teams(query), to: Queries
  defdelegate with_commissioner(query), to: Queries
  defdelegate with_season(query), to: Queries
  defdelegate get_all(query \\ League), to: Queries
  defdelegate create(league), to: Commands
end
