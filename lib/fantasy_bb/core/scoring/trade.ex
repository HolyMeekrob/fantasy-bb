defmodule FantasyBb.Core.Scoring.Trade do
  alias FantasyBb.Core.Scoring.Team

  import FantasyBb.Core.Utils.MapSet, only: [xor: 2]

  @enforce_keys [:week_number, :timestamp]
  defstruct [:week_number, :timestamp, houseguests: MapSet.new()]

  def create(%FantasyBb.Data.Schema.Trade{} = trade) do
    houseguests =
      Enum.map(trade.houseguests, &Map.fetch!(&1, :id))
      |> Enum.into(MapSet.new())

    %FantasyBb.Core.Scoring.Trade{
      week_number: trade.week.week_number,
      timestamp: trade.updated_at,
      houseguests: houseguests
    }
  end

  def process(trade, league) do
    team_is_involved = fn team ->
      not MapSet.disjoint?(team.houseguests, trade.houseguests)
    end

    update_team = fn team ->
      if team_is_involved.(team) do
        updated_houseguests = xor(team.houseguests, trade.houseguests)
        %Team{team | houseguests: updated_houseguests}
      else
        team
      end
    end

    updated_teams = Enum.map(league.teams, update_team)
    %{league | teams: updated_teams}
  end
end
