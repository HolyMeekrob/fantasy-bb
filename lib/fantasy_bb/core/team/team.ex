defmodule FantasyBb.Core.Team do
  alias FantasyBb.Core.Team.TeamState

  def initial_state(team) do
    TeamState.init(team)
  end
end
