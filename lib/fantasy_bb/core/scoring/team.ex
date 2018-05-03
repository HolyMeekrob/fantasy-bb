defmodule FantasyBb.Core.Scoring.Team do
  alias FantasyBb.Data.DraftPick
  alias FantasyBb.Data.Team

  @enforce_keys [:id]
  defstruct [:id, houseguests: MapSet.new(), points: 0]

  def create(%FantasyBb.Data.Schema.Team{} = team) do
    houseguests =
      team
      |> Team.get_draft_picks()
      |> Enum.map(&DraftPick.get_houseguest/1)
      |> Enum.map(&Map.fetch!(&1, :id))
      |> Enum.into(MapSet.new())

    %FantasyBb.Core.Scoring.Team{
      id: team.id,
      houseguests: houseguests
    }
  end
end
