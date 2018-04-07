defmodule FantasyBb.Core.Scoring.FinalCeremonyTest do
  use ExUnit.Case, async: true

  alias FantasyBb.Core.Scoring.JuryVote
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Season

  import FantasyBb.Core.Scoring.FinalCeremony, only: [process: 2]

  test "process final ceremony" do
    league = %League{
      id: 1,
      season: %Season{
        id: 2,
        hohs: MapSet.new([1]),
        otb: MapSet.new([5]),
        voters: MapSet.new([3]),
        evictees: MapSet.new([103, 381, 101])
      }
    }

    ceremony = %FantasyBb.Core.Scoring.FinalCeremony{
      votes: [
        %JuryVote{voter_id: 103, candidate_id: 1},
        %JuryVote{voter_id: 381, candidate_id: 3},
        %JuryVote{voter_id: 101, candidate_id: 5}
      ]
    }

    result = process(ceremony, league)

    assert(Enum.empty?(result.season.hohs), "heads of household should be cleared")
    assert(Enum.empty?(result.season.otb), "on the block should be cleared")
    assert(Enum.empty?(result.season.voters), "voters should be cleared")

    assert(
      MapSet.equal?(result.season.evictees, MapSet.new([1, 3, 5, 103, 101, 381])),
      "evictees should include everyone"
    )
  end
end
