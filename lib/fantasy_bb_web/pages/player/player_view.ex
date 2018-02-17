defmodule FantasyBbWeb.PlayerView do
  use FantasyBbWeb, :view

  def render("player.json", player) do
    %{
      first_name: player.first_name,
      last_name: player.last_name,
      nick_name: player.nick_name,
      birthday: player.birthday
    }
  end
end
