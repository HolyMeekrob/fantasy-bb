defmodule FantasyBb.Core.Team.TeamState do
  @enforce_keys [:id]
  defstruct [:id, houseguests: [], points: 0]

  def init(%FantasyBb.Data.Schema.Team{} = team, draft_picks) do
    get_team_id = fn draft_pick -> draft_pick.team.id end

    houseguests =
      draft_picks
      |> Enum.filter(&(get_team_id.(&1) == team.id))
      |> Enum.map(&Map.fetch!(&1, :houseguest))

    %FantasyBb.Core.Team.TeamState{
      id: team.id,
      houseguests: houseguests
    }
  end
end
