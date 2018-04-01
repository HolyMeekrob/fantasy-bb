defmodule FantasyBb.Core.EventTest do
  use ExUnit.Case, async: true
  use Quixir
  alias FantasyBb.Core.Scoring.Event

  test "hoh event" do
    ptest original_hohs: list(of: int()), new_hoh: int() do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: new_hoh,
        week_number: 1,
        order: 1,
        timestamp: NaiveDateTime.utc_now()
      }

      league = %FantasyBb.Core.Scoring.League{
        season: %FantasyBb.Core.Scoring.Season{
          hohs: original_hohs
        }
      }

      result = Event.process(event, league).season.hohs
      assert Enum.count(result) === Enum.count(original_hohs) + 1
      assert Enum.any?(result, &(&1 === new_hoh))
      assert Enum.all?(original_hohs, &Enum.member?(result, &1))
    end
  end
end
