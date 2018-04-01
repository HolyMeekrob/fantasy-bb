defmodule FantasyBb.Core.EventTest do
  use ExUnit.Case, async: true
  alias FantasyBb.Core.Scoring.Event

  describe "hoh event" do
    test "current hoh list is empty" do
      houseguest_id = 5

      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: houseguest_id,
        week_number: 1,
        order: 1,
        timestamp: NaiveDateTime.utc_now()
      }

      league = %FantasyBb.Core.Scoring.League{
        season: %FantasyBb.Core.Scoring.Season{
          hohs: []
        }
      }

      result = Event.process(event, league)
      assert Enum.count(result.season.hohs) === 1
      assert Enum.all?(result.season.hohs, &(&1 === houseguest_id))
    end

    test "current hoh list is non-empty" do
      houseguest_id = 9

      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: houseguest_id,
        week_number: 1,
        order: 1,
        timestamp: NaiveDateTime.utc_now()
      }

      league = %FantasyBb.Core.Scoring.League{
        season: %FantasyBb.Core.Scoring.Season{
          hohs: [2, 7]
        }
      }

      result = Event.process(event, league)
      assert Enum.count(result.season.hohs) === 3
      assert Enum.any?(result.season.hohs, &(&1 === houseguest_id))
      assert Enum.any?(result.season.hohs, &(&1 === 2))
      assert Enum.any?(result.season.hohs, &(&1 === 7))
    end
  end
end
