defmodule FantasyBb.Core.Scoring.EventTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias FantasyBb.Core.Scoring.Event

  test "hoh event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 0, 1, 0}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_hohs = league.season.hohs
      result = Event.process(event, league)
      updated_hohs = result.season.hohs

      assert(
        Enum.count(updated_hohs) === Enum.count(original_hohs) + 1,
        "there should be one more HoH"
      )

      assert(
        Enum.any?(updated_hohs, &(&1 === event.houseguest_id)),
        "event houseguest should be included in new HoHs"
      )

      assert(
        Enum.all?(original_hohs, &Enum.member?(updated_hohs, &1)),
        "all previous HoHs should still be present"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "new HoH should no longer be a voter"
      )
    end
  end

  test "final hoh round 1 event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
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
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
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

  test "pov event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 4,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)

      assert(
        result.season.pov === houseguest_id,
        "should update the pov holder"
      )
    end
  end

  test "nomination event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 0, 1, 0}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 5,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "there should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "nominee should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "nominee should no longer be a voter"
      )
    end
  end

  test "on the block event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 0, 1, 0}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 6,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "there should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "event houseguest should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "on the block houseguest should no longer be a voter"
      )
    end
  end

  test "off the block event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 1, 0, 0}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 7,
        houseguest_id: Enum.random(league.season.otb),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_voters = league.season.voters
      result = Event.process(event, league)
      updated_voters = result.season.voters

      assert(
        Enum.count(updated_voters) === Enum.count(original_voters) + 1,
        "there should be one more voter"
      )

      assert(
        Enum.any?(updated_voters, &(&1 === event.houseguest_id)),
        "event houseguest should be a voter"
      )

      assert(
        Enum.all?(original_voters, &Enum.member?(updated_voters, &1)),
        "all existing voters should still be there"
      )

      assert(
        not Enum.member?(result.season.otb, event.houseguest_id),
        "event houseguest should no longer be on the block"
      )
    end
  end

  test "replacement nomination event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 0, 1, 0}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 8,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "there should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "replacement nominee should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "replacement nominee should no longer be a voter"
      )
    end
  end

  test "return to the house event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              league <- league_generator({0, 0, 0, 1}) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 9,
        houseguest_id: Enum.random(league.season.evictees),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      original_voters = league.season.voters
      result = Event.process(event, league)
      updated_voters = result.season.voters

      assert(
        Enum.count(updated_voters) === Enum.count(original_voters) + 1,
        "there should be one more voter"
      )

      assert(
        Enum.any?(updated_voters, &(&1 === event.houseguest_id)),
        "returned houseguest should be a voter"
      )

      assert(
        Enum.all?(original_voters, &Enum.member?(updated_voters, &1)),
        "all prior voters should still be voters"
      )

      assert(
        not Enum.member?(result.season.evictees, event.houseguest_id),
        "returned houseguest should no longer be an evictee"
      )
    end
  end

  test "America's choice event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 10,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end

  test "competition event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 11,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end

  test "America's favorite player event" do
    check all week_number <- StreamData.positive_integer(),
              order <- StreamData.positive_integer(),
              houseguest_id <- StreamData.positive_integer(),
              league <- league_generator() do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 12,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end

  describe "Self-eviction event" do
    test "when houseguest is a voter" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({0, 0, 1, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.voters),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.voters, event.houseguest_id),
          "evictee should no longer be a voter"
        )
      end
    end

    test "when houseguest is an hoh" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({1, 0, 0, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.hohs),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.hohs, event.houseguest_id),
          "evictee should no longer be a Head of Household"
        )
      end
    end

    test "when houseguest is on the block" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({0, 1, 0, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.otb),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.otb, event.houseguest_id),
          "evictee should no longer be on the block"
        )
      end
    end
  end

  describe "Removal event" do
    test "when houseguest is a voter" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({0, 0, 1, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.voters),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.voters, event.houseguest_id),
          "evictee should no longer be a voter"
        )
      end
    end

    test "when houseguest is an hoh" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({1, 0, 0, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.hohs),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.hohs, event.houseguest_id),
          "evictee should no longer be a Head of Household"
        )
      end
    end

    test "when houseguest is on the block" do
      check all week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league <- league_generator({0, 1, 0, 0}) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.otb),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "there should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "all prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.otb, event.houseguest_id),
          "evictee should no longer be on the block"
        )
      end
    end
  end

  defp league_generator({min_hohs, min_otb, min_voters, min_evictees} \\ {0, 0, 0, 0}) do
    StreamData.map(
      StreamData.fixed_map(%{
        id: StreamData.positive_integer(),
        season: season_generator(min_hohs, min_otb, min_voters, min_evictees)
      }),
      struct_builder(FantasyBb.Core.Scoring.League)
    )
  end

  defp season_generator(min_hohs, min_otb, min_voters, min_evictees) do
    StreamData.map(
      StreamData.fixed_map(%{
        id: StreamData.positive_integer(),
        hohs: set_generator(1001, 2000, min_hohs),
        otb: set_generator(2001, 3000, min_otb),
        voters: set_generator(3001, 4000, min_voters),
        evictees: set_generator(4001, 5000, min_evictees)
      }),
      struct_builder(FantasyBb.Core.Scoring.Season)
    )
  end

  defp struct_builder(type) do
    fn obj -> struct(type, obj) end
  end

  defp set_generator(min, max, min_length) do
    StreamData.map(
      StreamData.list_of(
        StreamData.member_of(Enum.to_list(min..max)),
        min_length: min_length
      ),
      &MapSet.new/1
    )
  end
end
