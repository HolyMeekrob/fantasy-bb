defmodule FantasyBbWeb.TeamView do
  use FantasyBbWeb, :view

  def render("team.json", %{team: team}) do
    render("league.json", team)
  end

  def render("team.json", team) do
    %{
      id: team.id,
      name: team.name,
      ownerId: team.owner.id,
      ownerName: team.owner.first_name,
      points: 0,
      players: [],
      canEdit: true
    }
  end
end
