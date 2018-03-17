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
    |> Season.get_all()
  end

  def started?(season) do
    season.start <= Date.utc_today()
  end

  def completed?(season) do
    Enum.empty?(season.jury_votes)
  end

  def get_status(id) do
    season =
      Season.query()
      |> Season.with_jury_votes()
      |> Season.get(id)

    case {started?(season), completed?(season)} do
      {false, _} ->
        :upcoming

      {_, true} ->
        :current

      {_, _} ->
        :complete
    end
  end
end
