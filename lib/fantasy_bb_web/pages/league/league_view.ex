defmodule FantasyBbWeb.LeagueView do
  use FantasyBbWeb, :view

  def render("league_overview.json", %{league: league}) do
    %{
      id: league.id
    }
  end

  def render("user_leagues.json", %{leagues: leagues}) do
    render_many(leagues, __MODULE__, "league_overview.json")
  end
end
