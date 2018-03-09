defmodule FantasyBbWeb.LeagueController do
  use FantasyBbWeb, :controller

  def create_view(conn, _params) do
    render(conn, "create.html")
  end
end
