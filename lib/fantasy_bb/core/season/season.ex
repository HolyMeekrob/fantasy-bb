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

  def started?(season) do
    Date.compare(season.start, Date.utc_today()) == :lt
  end

  def completed?(season) do
    season
    |> Season.get_jury_votes()
    |> Enum.empty?()
    |> Kernel.not()
  end

  def status(season) do
    IO.puts("Season ID: " <> to_string(season.id))

    case {started?(season), completed?(season)} do
      {false, _completed} ->
        :upcoming

      {_started, false} ->
        :current

      {_started, _completed} ->
        :complete
    end
  end
end
