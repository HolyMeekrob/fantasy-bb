defmodule FantasyBbWeb.HomeController do
  use FantasyBbWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
