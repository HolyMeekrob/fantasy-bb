defmodule FantasyBbWeb.HouseguestView do
  use FantasyBbWeb, :view

  alias FantasyBbWeb.PlayerView

  def render("houseguest.json", houseguest) do
    %{
      id: houseguest.id,
      seasonId: houseguest.season_id,
      playerId: houseguest.player_id,
      hometown: houseguest.hometown
    }
  end

  def render("houseguest_with_player.json", %{houseguest: houseguest}) do
    render("houseguest_with_player.json", houseguest)
  end

  def render("houseguest_with_player.json", houseguest) do
    Map.merge(
      render("houseguest.json", houseguest),
      render(PlayerView, "player.json", houseguest.player)
    )
  end
end
