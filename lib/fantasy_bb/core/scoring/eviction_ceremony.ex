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

  def process(ceremony, league) do
    evictee = get_evictee(ceremony)
    evictees = MapSet.put(league.season.evictees, evictee)

    voters =
      league.season.voters
      |> MapSet.union(league.season.hohs)
      |> MapSet.union(MapSet.delete(league.season.otb, evictee))

    league = put_in(league.season.evictees, evictees)
    league = put_in(league.season.voters, voters)
    league = put_in(league.season.hohs, MapSet.new())
    put_in(league.season.otb, MapSet.new())
  end

  defp get_evictee(ceremony) do
    ceremony.votes
    |> Enum.group_by(&Map.fetch!(&1, :candidate_id))
    |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
    |> Enum.sort_by(fn {_, votes} -> votes end, &>/2)
    |> List.first()
    |> elem(0)
  end
end
