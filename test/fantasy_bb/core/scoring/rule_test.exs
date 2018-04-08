defmodule FantasyBb.Core.Scoring.RuleTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Season
  alias FantasyBb.Core.Scoring.Team

  @scorable_id 1
  describe "standard hoh" do
    test "is not an hoh event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.map(
                    StreamData.positive_integer(),
                    &(&1 + 1)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is not a standard eviction" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is the final head of household event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.constant(1),
                remaining_events <- remaining_events_generator(event_type_id) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a standard non-final hoh event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.constant(1),
                next_event <- event_generator(event_type_id),
                remaining_events <-
                  StreamData.map(remaining_events_generator(), &[next_event | &1]) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 2
  describe "double eviction hoh" do
    test "is not an hoh event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.map(
                    StreamData.positive_integer(),
                    &(&1 + 1)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is the final head of household event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                remaining_events <- remaining_events_generator(event_type_id) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a standard hoh event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.constant(1),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a double eviction event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(1),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                next_event <- event_generator(event_type_id),
                remaining_events <-
                  StreamData.map(remaining_events_generator(), &[next_event | &1]) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: houseguest_id,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id
          },
          events: [event | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 110,
              houseguests: MapSet.new([1, 2, 3, 5])
            },
            %Team{
              id: 2,
              points: -20,
              houseguests: MapSet.new([4, 11, 6])
            }
          ]
        }

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 110 + point_value)
        assert_team_has_points(result, 2, -20)
      end
    end
  end

  defp assert_team_has_points(league, team_id, points) do
    team = Enum.find(league.teams, &(Map.fetch!(&1, :id) === team_id))
    assert(team.points === points, "teams should have correct points")
  end

  defp event_generator(event_type_id) do
    StreamData.fixed_map(%{
      event_type_id: StreamData.constant(event_type_id),
      houseguest_id: StreamData.positive_integer(),
      week_number: StreamData.positive_integer(),
      order: StreamData.positive_integer(),
      timestamp: StreamData.constant(NaiveDateTime.utc_now())
    })
    |> StreamData.map(fn obj -> struct(Event, obj) end)
  end

  defp remaining_events_generator(excluded_event_type \\ 0) do
    event_type_generator =
      if excluded_event_type === 1 do
        StreamData.map(StreamData.positive_integer(), &(&1 + 1))
      else
        StreamData.filter(
          StreamData.positive_integer(),
          &(&1 !== excluded_event_type)
        )
      end

    StreamData.fixed_map(%{
      event_type_id: event_type_generator,
      houseguest_id: StreamData.positive_integer(),
      week_number: StreamData.positive_integer(),
      order: StreamData.positive_integer(),
      timestamp: StreamData.constant(NaiveDateTime.utc_now())
    })
    |> StreamData.map(fn obj -> struct(Event, obj) end)
    |> StreamData.list_of()
  end
end
