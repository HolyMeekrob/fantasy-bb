defmodule FantasyBb.Core.League do
  alias FantasyBb.Data.League

  defdelegate get_league_scores(league), to: FantasyBb.Core.Scoring

  def create(league) do
    League.create(league)
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
