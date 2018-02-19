defmodule FantasyBbWeb.PlayerController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Player

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
end
