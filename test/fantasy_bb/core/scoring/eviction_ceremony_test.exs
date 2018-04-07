defmodule FantasyBb.Core.Scoring.EvictionCeremonyTest do
  use ExUnit.Case, async: true

  alias FantasyBb.Core.Scoring.EvictionVote
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Season

  import FantasyBb.Core.Scoring.EvictionCeremony, only: [process: 2]

  describe "process eviction ceremony" do
    test "only one vote" do
      league = %League{
        id: 1,
        season: %Season{
          id: 1,
          hohs: MapSet.new([1]),
          otb: MapSet.new([7, 5]),
          voters: MapSet.new([3]),
          evictees: MapSet.new([103, 381, 101])
        }
      }

      ceremony = %FantasyBb.Core.Scoring.EvictionCeremony{
        week_number: 1,
        order: 2,
        timestamp: NaiveDateTime.utc_now(),
        votes: [
          %EvictionVote{voter_id: 3, candidate_id: 5}
        ]
      }

      result = process(ceremony, league)

      assert(Enum.empty?(result.season.hohs), "heads of household should be cleared")
      assert(Enum.empty?(result.season.otb), "on the block should be cleared")

      assert(
        MapSet.equal?(result.season.voters, MapSet.new([1, 7, 3])),
        "voters should be everyone except evictee"
      )

      assert(MapSet.equal?(result.season.evictees, MapSet.new([103, 381, 101, 5])))
    end

    test "multiple unanimous votes" do
      league = %League{
        id: 1,
        season: %Season{
          id: 2,
          hohs: MapSet.new([1]),
          otb: MapSet.new([7, 5]),
          voters: MapSet.new([3, 10, 20]),
          evictees: MapSet.new([103, 381, 101])
        }
      }

      ceremony = %FantasyBb.Core.Scoring.EvictionCeremony{
        week_number: 3,
        order: 4,
        timestamp: NaiveDateTime.utc_now(),
        votes: [
          %EvictionVote{voter_id: 3, candidate_id: 5},
          %EvictionVote{voter_id: 10, candidate_id: 5},
          %EvictionVote{voter_id: 20, candidate_id: 5}
        ]
      }

      result = process(ceremony, league)

      assert(Enum.empty?(result.season.hohs), "heads of household should be cleared")
      assert(Enum.empty?(result.season.otb), "on the block should be cleared")

      assert(
        MapSet.equal?(result.season.voters, MapSet.new([1, 7, 3, 10, 20])),
        "voters should be everyone except evictee"
      )

      assert(MapSet.equal?(result.season.evictees, MapSet.new([103, 381, 101, 5])))
    end

    test "split votes between two candidates" do
      league = %League{
        id: 5,
        season: %Season{
          id: 6,
          hohs: MapSet.new([1]),
          otb: MapSet.new([7, 5]),
          voters: MapSet.new([3, 10, 20]),
          evictees: MapSet.new([103, 381, 101])
        }
      }

      ceremony = %FantasyBb.Core.Scoring.EvictionCeremony{
        week_number: 3,
        order: 1,
        timestamp: NaiveDateTime.utc_now(),
        votes: [
          %EvictionVote{voter_id: 3, candidate_id: 7},
          %EvictionVote{voter_id: 10, candidate_id: 5},
          %EvictionVote{voter_id: 20, candidate_id: 7}
        ]
      }

      result = process(ceremony, league)
      assert(Enum.empty?(result.season.hohs), "heads of household should be cleared")
      assert(Enum.empty?(result.season.otb), "on the block should be cleared")

      assert(
        MapSet.equal?(result.season.voters, MapSet.new([1, 5, 3, 10, 20])),
        "voters should be everyone except evictee"
      )

      assert(MapSet.equal?(result.season.evictees, MapSet.new([103, 381, 101, 7])))
    end

    test "split votes between more than two candidates" do
      league = %League{
        id: 4,
        season: %Season{
          id: 44,
          hohs: MapSet.new([1]),
          otb: MapSet.new([7, 5, 11]),
          voters: MapSet.new([3, 10, 20, 25, 22, 99]),
          evictees: MapSet.new([103, 381, 101])
        }
      }

      ceremony = %FantasyBb.Core.Scoring.EvictionCeremony{
        week_number: 444,
        order: 4444,
        timestamp: NaiveDateTime.utc_now(),
        votes: [
          %EvictionVote{voter_id: 3, candidate_id: 7},
          %EvictionVote{voter_id: 10, candidate_id: 5},
          %EvictionVote{voter_id: 20, candidate_id: 7},
          %EvictionVote{voter_id: 25, candidate_id: 11},
          %EvictionVote{voter_id: 22, candidate_id: 7},
          %EvictionVote{voter_id: 99, candidate_id: 11}
        ]
      }

      result = process(ceremony, league)
      assert(Enum.empty?(result.season.hohs), "heads of household should be cleared")
      assert(Enum.empty?(result.season.otb), "on the block should be cleared")

      assert(
        MapSet.equal?(result.season.voters, MapSet.new([1, 5, 3, 10, 11, 20, 22, 25, 99])),
        "voters should be everyone except evictee"
      )

      assert(MapSet.equal?(result.season.evictees, MapSet.new([103, 381, 101, 7])))
    end
  end
end
