defmodule FantasyBb.Core.League do
  alias FantasyBb.Data.League
  import FantasyBb.Core.Scoring, only: [get_league_scores: 1]

  def create(league) do
    League.create(league)
  end

  def get_leagues_for_user(user_id) do
    get_league_with_score = fn league ->
      {league, get_league_scores(league)}
    end

    League.query()
    |> League.for_user(user_id)
    |> League.get_all()
    |> Enum.map(get_league_with_score)
  end
end
