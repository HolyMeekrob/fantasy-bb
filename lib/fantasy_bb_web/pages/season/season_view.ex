defmodule FantasyBbWeb.SeasonView do
  use FantasyBbWeb, :view

  def render("season.json", season) do
    %{
      id: season.id,
      title: season.title,
      start: season.start
    }
  end
end
