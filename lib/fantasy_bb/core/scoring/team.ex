defmodule FantasyBb.Core.Scoring.Team do
  alias FantasyBb.Data.DraftPick
  alias FantasyBb.Data.Team

  defstruct houseguests: [], points: 0

  def create(%FantasyBb.Data.Schema.Team{} = team) do
    houseguests =
      team
      |> Team.get_draft_picks()
      |> Enum.map(&DraftPick.get_houseguest/1)

    %FantasyBb.Core.Scoring.Team{
      houseguests: houseguests
    }
  end
end
