defmodule FantasyBbWeb.SeasonController do
  use FantasyBbWeb, :controller

  def create(conn, _params) do
    render(conn, "create.html")
  end
end
