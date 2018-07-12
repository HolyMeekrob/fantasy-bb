defmodule FantasyBbWeb.TeamView do
  use FantasyBbWeb, :view

  def render("team.json", %{team: team}) do
    render("league.json", team)
  end

  def render("team.json", team) do
    get_houseguest = fn houseguest_id ->
      houseguest =
        Enum.find(
          team.league.season.houseguests,
          &(Map.fetch!(&1, :id) === houseguest_id)
        )

      %{
        id: houseguest_id,
        name: houseguest.player.first_name,
        points: 0
      }
    end

    %{
      id: team.id,
      name: team.name,
      ownerId: team.owner.id,
      ownerName: team.owner.first_name,
      points: team.points,
      players: Enum.map(team.houseguests, get_houseguest),
      canEdit: true
    }
  end
end
