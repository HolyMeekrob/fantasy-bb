defmodule FantasyBb.Core.Team.TeamState do
  alias FantasyBb.Data.DraftPick
  alias FantasyBb.Data.Team

  @enforce_keys [:id, :user_id, :name]
  defstruct [:id, :user_id, :name, houseguests: [], points: 0]

  def init(%FantasyBb.Data.Schema.Team{} = team) do
    houseguests =
      team
      |> Team.get_draft_picks()
      |> Enum.map(&DraftPick.get_houseguest/1)

    %FantasyBb.Core.Team.TeamState{
      id: team.id,
      name: team.name,
      user_id: team.user_id,
      houseguests: houseguests
    }
  end
end
