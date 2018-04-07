defmodule FantasyBb.Core.Scoring.TradeTest do
  use ExUnit.Case, async: true
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Season
  alias FantasyBb.Core.Scoring.Team
  alias FantasyBb.Core.Scoring.Trade

  describe "process trade" do
    test "empty trade" do
      trade = %Trade{
        week_number: 1,
        timestamp: NaiveDateTime.utc_now(),
        houseguests: MapSet.new()
      }

      league = %League{
        id: 1,
        season: %Season{
          id: 1
        },
        teams: [
          %Team{
            id: 1,
            houseguests: MapSet.new([1, 2, 3]),
            points: 1
          },
          %Team{
            id: 2,
            houseguests: MapSet.new([4, 5]),
            points: -22
          },
          %Team{
            id: 3,
            houseguests: MapSet.new([6, 7, 8, 9]),
            points: 11
          }
        ]
      }

      result = Trade.process(trade, league)
      assert(league === result, "teams should not change")
    end

    test "one-for one trade" do
      trade = %Trade{
        week_number: 1,
        timestamp: NaiveDateTime.utc_now(),
        houseguests: MapSet.new([2, 7])
      }

      league = %League{
        id: 1,
        season: %Season{
          id: 1
        },
        teams: [
          %Team{
            id: 1,
            houseguests: MapSet.new([1, 2, 3]),
            points: 1
          },
          %Team{
            id: 2,
            houseguests: MapSet.new([4, 5]),
            points: -22
          },
          %Team{
            id: 3,
            houseguests: MapSet.new([6, 7, 8, 9]),
            points: 11
          }
        ]
      }

      result = Trade.process(trade, league)
      updated_team_one = Enum.find(result.teams, get_by_id(1)).houseguests
      updated_team_two = Enum.find(result.teams, get_by_id(2)).houseguests
      updated_team_three = Enum.find(result.teams, get_by_id(3)).houseguests

      assert(
        MapSet.equal?(updated_team_one, MapSet.new([1, 3, 7])),
        "team should have traded houseguests"
      )

      assert(
        MapSet.equal?(updated_team_two, MapSet.new([4, 5])),
        "team should be unchanged"
      )

      assert(
        MapSet.equal?(updated_team_three, MapSet.new([2, 6, 8, 9])),
        "team should have traded houseguests"
      )
    end

    test "two-for two trade" do
      trade = %Trade{
        week_number: 1,
        timestamp: NaiveDateTime.utc_now(),
        houseguests: MapSet.new([5, 8, 9, 11])
      }

      league = %League{
        id: 1,
        season: %Season{
          id: 1
        },
        teams: [
          %Team{
            id: 1,
            houseguests: MapSet.new([1, 2, 3]),
            points: 1
          },
          %Team{
            id: 2,
            houseguests: MapSet.new([4, 5, 10, 11, 12]),
            points: -22
          },
          %Team{
            id: 3,
            houseguests: MapSet.new([6, 7, 8, 9]),
            points: 11
          }
        ]
      }

      result = Trade.process(trade, league)
      updated_team_one = Enum.find(result.teams, get_by_id(1)).houseguests
      updated_team_two = Enum.find(result.teams, get_by_id(2)).houseguests
      updated_team_three = Enum.find(result.teams, get_by_id(3)).houseguests

      assert(
        MapSet.equal?(updated_team_one, MapSet.new([1, 2, 3])),
        "team should be unchanged"
      )

      assert(
        MapSet.equal?(updated_team_two, MapSet.new([4, 8, 9, 10, 12])),
        "team should have traded houseguests"
      )

      assert(
        MapSet.equal?(updated_team_three, MapSet.new([5, 6, 7, 11])),
        "team should have traded houseguests"
      )
    end

    test "one for two trade" do
      trade = %Trade{
        week_number: 1,
        timestamp: NaiveDateTime.utc_now(),
        houseguests: MapSet.new([4, 6, 9])
      }

      league = %League{
        id: 1,
        season: %Season{
          id: 1
        },
        teams: [
          %Team{
            id: 1,
            houseguests: MapSet.new([1, 2, 3]),
            points: 1
          },
          %Team{
            id: 2,
            houseguests: MapSet.new([4, 5]),
            points: -22
          },
          %Team{
            id: 3,
            houseguests: MapSet.new([6, 7, 8, 9]),
            points: 11
          }
        ]
      }

      result = Trade.process(trade, league)
      updated_team_one = Enum.find(result.teams, get_by_id(1)).houseguests
      updated_team_two = Enum.find(result.teams, get_by_id(2)).houseguests
      updated_team_three = Enum.find(result.teams, get_by_id(3)).houseguests

      assert(
        MapSet.equal?(updated_team_one, MapSet.new([1, 2, 3])),
        "team should be unchanged"
      )

      assert(
        MapSet.equal?(updated_team_two, MapSet.new([5, 6, 9])),
        "team should have traded houseguests"
      )

      assert(
        MapSet.equal?(updated_team_three, MapSet.new([4, 7, 8])),
        "team should have traded houseguests"
      )
    end
  end

  defp get_by_id(id) do
    fn map -> Map.fetch!(map, :id) === id end
  end
end
