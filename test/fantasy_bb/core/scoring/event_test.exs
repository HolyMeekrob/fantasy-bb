defmodule FantasyBb.Core.EventTest do
  use ExUnit.Case, async: true
  use Quixir
  alias FantasyBb.Core.Scoring.Event

  test "hoh event" do
    ptest houseguest_id: int(),
          week_number: int(),
          order: int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int())
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_hohs = league.season.hohs
      result = Event.process(event, league).season.hohs

      assert(
        Enum.count(result) === Enum.count(original_hohs) + 1,
        "There should be one more HoH"
      )

      assert(
        Enum.any?(result, &(&1 === houseguest_id)),
        "Event houseguest should be included in new HoHs"
      )

      assert(
        Enum.all?(original_hohs, &Enum.member?(result, &1)),
        "All previous hohs should still be presnet"
      )
    end
  end

  test "final hoh round 1 event" do
    ptest houseguest_id: int(),
          week_number: int(),
          order: int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 2,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end

  test "final hoh round 2 event" do
    ptest houseguest_id: int(),
          week_number: int(),
          order: int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 3,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end
end
