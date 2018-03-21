defmodule FantasyBb.Core.Team do
  alias FantasyBb.Core.Team.TeamState

  def initial_state(team, draft_picks) do
    TeamState.init(team, draft_picks)
  end
end
