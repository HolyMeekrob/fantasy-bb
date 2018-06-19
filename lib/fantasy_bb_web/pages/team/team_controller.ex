defmodule FantasyBbWeb.TeamController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.Team

  def show(conn, %{"id" => _}) do
    render(conn, "show.html")
  end

  def get(conn, %{"id" => id}) do
    team = Team.get_overview(id)
    render(conn, "team.json", team)
  end
end
