defmodule FantasyBbWeb.SeasonController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Repo
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

  def show(conn, %{"id" => _}) do
    render(conn, "show.html")
  end

  def get(conn, %{"id" => id}) do
    season =
      Season.query()
      |> Season.with_players()
      |> Repo.get(id)

    case season do
      nil ->
        send_resp(conn, :bad_request, "Season #{id} does not exist")

      _ ->
        render(conn, "season_with_players.json", season)
    end
  end

  def update(conn, %{"id" => id, "title" => title, "start" => start}) do
    input = %{title: title, start: Date.from_iso8601!(start)}

    case Season.update(id, input) do
      {:ok, season} ->
        render(conn, "season.json", season)

      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error updating season")
    end
  end
end
