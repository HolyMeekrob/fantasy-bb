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
    fn {league, scores} -> league_overview(user_id, league, scores) end
  end

  defp league_overview(user_id, league, scores) do
    score_sort = fn score_1, score_2 ->
      Map.fetch!(score_1, :points) >= Map.fetch!(score_2, :points)
    end

    user_team = Enum.find(league.teams, &(&1.user_id == user_id))

    %{
      id: league.id,
      name: league.name,
      teamName: user_team.name,
      teamRank:
        scores
        |> Enum.sort(score_sort)
        |> Enum.find_index(&(Map.fetch!(&1, :id) === user_team.id))
        |> (&(&1 + 1)).(),
      teamCount: length(league.teams)
    }
  end
end
