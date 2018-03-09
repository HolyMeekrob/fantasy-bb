defmodule FantasyBbWeb.PlayerView do
  use FantasyBbWeb, :view

  def render("player.json", %{player: player}) do
    render("player.json", player)
  end

  def render("player.json", player) do
    %{
      id: player.id,
      firstName: player.first_name,
      lastName: player.last_name,
      nickname: player.nickname,
      birthday: player.birthday,
      hometown: player.hometown
    }
  end

  def render("players.json", %{players: players}) do
    render_many(players, __MODULE__, "player.json")
  end
end
