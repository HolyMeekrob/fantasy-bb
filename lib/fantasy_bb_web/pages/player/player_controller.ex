defmodule FantasyBbWeb.PlayerController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Player

  def create_view(conn, _params) do
    render(conn, "create.html")
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

  def update(conn, %{"id" => id} = params) do
    with :ok <- Player.authorize(:update, conn.assigns.current_user),
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
