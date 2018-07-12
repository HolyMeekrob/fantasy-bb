defmodule FantasyBbWeb.TeamController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.League
  alias FantasyBb.Core.Team

  def show(conn, %{"id" => _}) do
    render(conn, "show.html")
  end

  def get(conn, %{"id" => id}) do
    team = Team.get_overview(id)

    team =
      team.league_id
      |> League.get_league_scores()
      |> Enum.find(&(Map.fetch!(&1, :id) === String.to_integer(id)))
      |> Map.merge(team)

    render(conn, "team.json", team)
  end
end
