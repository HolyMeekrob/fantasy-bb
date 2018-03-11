defmodule FantasyBbWeb.SeasonController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Repo
  alias FantasyBb.Season
  alias FantasyBb.Player

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, params) do
    with :ok <- Season.authorize(:create, conn.assigns.current_user),
         {:ok, start} <- Map.get(params, "start") |> Date.from_iso8601(),
         input = %FantasyBb.Schema.Season{
           title: Map.get(params, "title"),
           start: start
         },
         {:ok, season} <- Season.create(input) do
      conn
      |> put_status(:created)
      |> render("season.json", season)
    else
      {:error, :unauthorized} ->
        send_resp(
          conn,
          :unauthorized,
          "User is not authorized to create seasons"
        )

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

  def get_upcoming(conn, params) do
    seasons = Season.get_upcoming()
    render(conn, "seasons.json", seasons: seasons)
  end

  def update(conn, %{"id" => id} = params) do
    players =
      Map.get(params, "players", [])
      |> Player.get()

    with :ok <- Season.authorize(:update, conn.assigns.current_user),
         input = %{
           title: Map.get(params, "title"),
           start: Map.get(params, "start"),
           players: players
         },
         {:ok, season} <- Season.update(id, input) do
      render(conn, "season.json", season)
    else
      {:error, :unauthorized} ->
        send_resp(
          conn,
          :unauthorized,
          "User is not authorized to update seasons"
        )

      {:error, msg} ->
        send_resp(conn, :internal_server_error, "Error updating season: " <> msg)
    end
  end
end
