defmodule FantasyBb.Core.Scoring.EvictionCeremony do
  alias FantasyBb.Core.Scoring.EvictionVote

  @enforce_keys [:week_number, :order, :timestamp]
  defstruct [:week_number, :order, :timestamp, votes: []]

  def create(%FantasyBb.Data.Schema.EvictionCeremony{} = ceremony) do
    %FantasyBb.Core.Scoring.EvictionCeremony{
      week_number: ceremony.week.week_number,
      order: ceremony.order,
      timestamp: ceremony.inserted_at,
      votes: Enum.map(ceremony.eviction_votes, &EvictionVote.create/1)
    }
  end

  def process(ceremony, league) do
    evictee = get_evictee(ceremony)

    evictees =
      if is_nil(evictee) do
        league.season.evictees
      else
        MapSet.put(league.season.evictees, evictee)
      end

    voters =
      league.season.voters
      |> MapSet.delete(evictee)
      |> MapSet.union(league.season.hohs)
      |> MapSet.union(MapSet.delete(league.season.otb, evictee))

    league = put_in(league.season.pov, nil)
    league = put_in(league.season.evictees, evictees)
    league = put_in(league.season.voters, voters)
    league = put_in(league.season.hohs, MapSet.new())
    put_in(league.season.otb, MapSet.new())
  end

  defp get_evictee(%FantasyBb.Core.Scoring.EvictionCeremony{votes: votes})
       when length(votes) === 0 do
    nil
  end

  defp get_evictee(%FantasyBb.Core.Scoring.EvictionCeremony{votes: votes}) do
    votes
    |> Enum.group_by(&Map.fetch!(&1, :candidate_id))
    |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
    |> Enum.sort_by(fn {_id, votes} -> votes end, &>/2)
    |> List.first()
    |> elem(0)
  end
end
