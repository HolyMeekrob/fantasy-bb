defmodule FantasyBb.Core.Scoring.Trade do
  @enforce_keys [:week_number, :timestamp]
  defstruct [:week_number, :timestamp, houseguests: []]

  def create(%FantasyBb.Data.Schema.Trade{} = trade) do
    houseguests = Enum.map(trade.houseguests, &Map.fetch!(&1, :id))

    %FantasyBb.Core.Scoring.Trade{
      week_number: trade.week.week_number,
      timestamp: trade.updated_at,
      houseguests: houseguests
    }
  end
end
