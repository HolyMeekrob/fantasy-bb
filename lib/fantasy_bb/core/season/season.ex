defmodule FantasyBb.Core.Season do
  alias FantasyBb.Data.Season

  def create(season) do
    Season.create(season)
  end

  def update(id, changes) do
    Season.update(id, changes)
  end

  def get_season_players(season_id) do
    Season.query()
    |> Season.with_players()
    |> Season.get(season_id)
  end

  def get_upcoming_seasons() do
    Season.get_upcoming()
  end
end
