defmodule FantasyBb.Core.Scoring.EvictionCeremony do
  alias FantasyBb.Core.Scoring.EvictionVote

  @enforce_keys [:week_number, :order, :timestamp]
  defstruct [:week_number, :order, :timestamp, votes: []]

  def create([head | _] = votes) do
    ceremony = head.eviction_ceremony

    %FantasyBb.Core.Scoring.EvictionCeremony{
      week_number: ceremony.week.week_number,
      order: ceremony.order,
      timestamp: ceremony.inserted_at,
      votes: Enum.map(votes, &EvictionVote.create/1)
    }
  end
end
