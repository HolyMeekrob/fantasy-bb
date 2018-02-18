defmodule FantasyBbWeb.PlayerView do
  use FantasyBbWeb, :view

  def render("player.json", player) do
    %{
      firstName: player.first_name,
      lastName: player.last_name,
      nickname: player.nick_name,
      birthday: player.birthday
    }
  end
end
