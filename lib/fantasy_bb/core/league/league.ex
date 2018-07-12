defmodule FantasyBb.Core.League do
  alias FantasyBb.Data.League

  def create(league) do
    League.create(league)
  end

  def get_league_scores(league_id) when is_integer(league_id) do
    league_id
    |> get_overview()
    |> get_league_scores()
  end

  def get_league_scores(league) do
    FantasyBb.Core.Scoring.get_league_scores(league)
  end

  def get_overview(league_id) do
    League.query()
    |> League.for_overview()
    |> League.get(league_id)
  end

  def get_leagues_for_user(user_id) do
    League.query()
    |> League.for_user(user_id)
    |> League.get_all()
  end
end
