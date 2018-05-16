defmodule FantasyBb.Data.League do
  alias FantasyBb.Data.League.Accessors
  alias FantasyBb.Data.League.Commands
  alias FantasyBb.Data.League.Queries
  alias FantasyBb.Data.Schema.League

  defdelegate get(id), to: Queries
  defdelegate get(query, id), to: Queries
  defdelegate query(), to: Queries
  defdelegate for_overview(query), to: Queries
  defdelegate for_user(query, user_id), to: Queries
  defdelegate get_all(query \\ League), to: Queries

  defdelegate create(league), to: Commands

  defdelegate get_rules(league), to: Accessors
  defdelegate get_season(league), to: Accessors
end
