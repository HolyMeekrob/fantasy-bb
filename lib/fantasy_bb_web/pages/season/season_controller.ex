defmodule FantasyBbWeb.SeasonController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Season

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, %{"title" => title, "start" => start}) do
    input = %FantasyBb.Schema.Season{
      title: title,
      start: Date.from_iso8601!(start)
    }

    case Season.create(input) do
      {:ok, season} ->
        render(conn, "season.json", season)

      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error creating season")
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html")
  end
end
