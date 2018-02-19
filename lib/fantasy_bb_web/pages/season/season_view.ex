defmodule FantasyBbWeb.SeasonView do
  use FantasyBbWeb, :view

  alias FantasyBbWeb.PlayerView

  def render("season.json", season) do
    %{
      id: season.id,
      title: season.title,
      start: season.start
    }
  end

  def render("season_with_players.json", season) do
    render("season.json", season)
    |> Map.put(
      :players,
      render_many(
        season.players,
        PlayerView,
        "player.json"
      )
    )
  end
end
