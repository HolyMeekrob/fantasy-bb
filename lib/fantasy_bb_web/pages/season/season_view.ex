defmodule FantasyBbWeb.SeasonView do
  use FantasyBbWeb, :view

  alias FantasyBbWeb.HouseguestView

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
      :houseguests,
      render_many(
        season.houseguests,
        HouseguestView,
        "houseguest_with_player.json"
      )
    )
  end
end
