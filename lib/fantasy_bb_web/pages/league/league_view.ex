defmodule FantasyBbWeb.LeagueView do
  use FantasyBbWeb, :view

  alias FantasyBb.Core.Season

  import FantasyBb.Core.Utils.Function, only: [identity: 1]
  import FantasyBb.Core.Utils.Map, only: [map: 2]

  def render("league_overview.json", %{league: league}) do
    %{
      id: league.id
    }
  end

  def render("user_leagues.json", %{leagues: leagues}) do
    leagues
    |> Enum.group_by(&Season.status(&1.season), &identity/1)
    |> map(&render_many(&1, __MODULE__, "league_overview.json"))
  end
end
