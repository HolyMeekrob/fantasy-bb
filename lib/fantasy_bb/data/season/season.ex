defmodule FantasyBb.Data.Season do
  alias FantasyBb.Data.Season.Commands
  alias FantasyBb.Data.Season.Queries
  alias FantasyBb.Data.Schema.Season
  alias FantasyBb.Repo

  defdelegate get(id), to: Queries
  defdelegate get(query, id), to: Queries
  defdelegate get_all(query \\ Season), to: Queries
  defdelegate get_upcoming(query \\ Season), to: Queries
  defdelegate query(), to: Queries
  defdelegate with_jury_votes(query), to: Queries
  defdelegate with_players(query), to: Queries
  defdelegate create(season), to: Commands
  defdelegate update(id, changes), to: Commands

  def load_jury_votes(season) do
    Repo.preload(season, :jury_votes)
  end
end
