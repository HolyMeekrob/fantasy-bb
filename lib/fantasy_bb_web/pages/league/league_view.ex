defmodule FantasyBbWeb.LeagueView do
  use FantasyBbWeb, :view

  alias FantasyBb.Core.Season

  import FantasyBb.Core.Utils.Map, only: [map: 2]

  def render("league_overview.json", %{league: league}) do
    league
  end

  def render("user_leagues.json", %{leagues: leagues, user_id: user_id}) do
    get_season_status = fn {league, _scoring} ->
      league
      |> Map.fetch!(:season)
      |> Season.status()
    end

    leagues
    |> Enum.group_by(get_season_status, league_overview(user_id))
    |> map(&render_many(&1, __MODULE__, "league_overview.json"))
  end

  defp league_overview(user_id) do
    fn {league, _} -> league_overview(user_id, league) end
  end

  defp league_overview(user_id, league) do
    %{
      id: league.id,
      name: league.name,
      team_name:
        league.teams
        |> Enum.find(&(&1.user_id == user_id))
        |> Map.fetch!(:name)
    }
  end
end
