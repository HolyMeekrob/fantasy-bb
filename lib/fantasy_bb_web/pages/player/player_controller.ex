defmodule FantasyBbWeb.PlayerController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.Player

  import FantasyBb.Core.Utils.Nil, only: [with_default: 2]
  import FantasyBbWeb.Player.Authorization, only: [authorize: 2]

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, params) do
    birthday =
      with {:ok, dateVal} <- Map.fetch(params, "birthday"),
           dateStr <- with_default(dateVal, ""),
           {:ok, date} <- Date.from_iso8601(dateStr) do
        date
      else
        :error ->
          nil

        _ ->
          Map.fetch!(params, "birthday")
      end

    with :ok <- authorize(:create, conn.assigns.current_user),
         input = %{
           first_name: Map.get(params, "firstName"),
           last_name: Map.get(params, "lastName"),
           nickname: Map.get(params, "nickname"),
           hometown: Map.get(params, "hometown"),
           birthday: birthday
         },
         {:ok, player} <- Player.create(input) do
      conn
      |> put_status(:created)
      |> render("player.json", player)
    else
      {:error, :unauthorized} ->
        send_resp(
          conn,
          :unauthorized,
          "User is not authorized to create players"
        )

      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error creating player")
    end
  end

  def show(conn, %{"id" => _}) do
    render(conn, "show.html")
  end

  def get(conn, %{"id" => id}) do
    player = Player.get(id)

    case player do
      nil ->
        send_resp(conn, :bad_request, "Player #{id} does not exist")

      _ ->
        render(conn, "player.json", player)
    end
  end

  def index(conn, _) do
    render(conn, "players.json", players: Player.get_all())
  end

  def update(conn, %{"id" => id} = params) do
    with :ok <- authorize(:update, conn.assigns.current_user),
         input = %{
           first_name: Map.get(params, "firstName"),
           last_name: Map.get(params, "lastName"),
           nickname: Map.get(params, "nickname"),
           hometown: Map.get(params, "hometown"),
           birthday: Map.get(params, "birthday")
         },
         {:ok, player} <- Player.update(id, input) do
      render(conn, "player.json", player)
    else
      {:error, :unauthorized} ->
        send_resp(
          conn,
          :unauthorized,
          "User is not authorized to update players"
        )

      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error updating player")
    end
  end
end
