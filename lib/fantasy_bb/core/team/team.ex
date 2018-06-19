defmodule FantasyBb.Core.Team do
  alias FantasyBb.Data.Team

  def get_overview(team_id) do
    Team.query()
    |> Team.for_overview()
    |> Team.get(team_id)
  end
end
