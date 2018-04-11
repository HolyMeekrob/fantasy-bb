defmodule FantasyBb.Core.Scoring.RuleTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Season
  alias FantasyBb.Core.Scoring.Team

  @scorable_id 1
  describe "standard head of household" do
    test "is not an head of household event" do
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

    test "is a standard non-final head of household event" do
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
  describe "double eviction head of household" do
    test "is not an head of household event" do
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

    test "is a standard head of household event" do
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

  @scorable_id 3
  describe "final head of household - round one" do
    test "is not a final head of household round one event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 2)
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

    test "is a final head of household round one event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <- StreamData.constant(2) do
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

  @scorable_id 4
  describe "final head of household - round two" do
    test "is not a final head of household round two event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 3)
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

    test "is a final head of household round two event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <- StreamData.constant(3) do
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

  @scorable_id 5
  describe "final head of household" do
    test "is not an head of household event" do
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

    test "is a non-final head of household event" do
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 6
  describe "standard power of veto" do
    test "is not a power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 4)
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

    test "is not a standard power of veto" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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

    test "is the final power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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

    test "is a standard non-final power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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

  @scorable_id 7
  describe "double eviction power of veto" do
    test "is not a power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 4)
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

    test "is the final power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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

    test "is a standard power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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
                event_type_id <- StreamData.constant(4),
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

  @scorable_id 8
  describe "final power of veto" do
    test "is not a power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 4)
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

    test "is a non-final power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is the final power of veto event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(4),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 9
  describe "standard nomination" do
    test "is not a nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 5)
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

    test "is not a standard nomination" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(5),
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

    test "is a standard nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(5),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 10
  describe "double eviction nomination" do
    test "is not a nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 5)
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

    test "is a standard nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(5),
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

    test "is a double eviction nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(5),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 11
  describe "houseguest on the block" do
    test "is not an on the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 6)
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

    test "is an on the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(6),
                order <- StreamData.positive_integer(),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 12
  describe "use veto on self during a standard eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: houseguest_id
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

    test "is not a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: houseguest_id
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

    test "veto holder is not the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: 1
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

    test "veto holder takes self off the block during a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: houseguest_id
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

  @scorable_id 13
  describe "use veto on self during a double eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: houseguest_id
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

    test "is not a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: houseguest_id
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

    test "veto holder is not the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1
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

    test "veto holder takes self off the block during a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
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
            id: season_id,
            pov: houseguest_id
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

  @scorable_id 14
  describe "use veto on another whilst not on the block during a standard eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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

    test "is not a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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

    test "veto holder is the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([5])
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

    test "veto holder is also on the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "veto holder takes another off the block whilst not on the block during a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 15
  describe "use veto on another whilst not on the block during a double eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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

    test "is not a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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

    test "veto holder is the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([5])
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

    test "veto holder is also on the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "veto holder takes another off the block whilst not on the block during a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([5])
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
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 16
  describe "use veto on another whilst on the block during a standard eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "is not a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "veto holder is the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([1, 5])
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

    test "veto holder is not on the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([2, 5])
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

    test "veto holder takes another off the block whilst on the block during a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 17
  describe "use veto on another whilst on the block during a double eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "is not a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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

    test "veto holder is the houseguest taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([1, 5])
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

    test "veto holder is not on the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([2, 5])
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

    test "veto holder takes another off the block whilst on the block during a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([1, 5])
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
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 18
  describe "abstain from veto whilst not on the block during a standard eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

    test "is not a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

    test "houseguest is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                houseguest_id <- StreamData.member_of([1, 2, 3, 4, 5, 6]) do
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
            id: season_id,
            pov: 1
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

    test "veto holder abstains from veto during a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

  @scorable_id 19
  describe "abstain from veto whilst not on the block during a double eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

    test "is not a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

    test "houseguest is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                houseguest_id <- StreamData.member_of([1, 2, 3, 4, 5, 6]) do
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
            id: season_id,
            pov: 1
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

    test "veto holder abstains from veto during a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id
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

  @scorable_id 20
  describe "abstain from veto whilst on the block during a standard eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

    test "is not a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

    test "houseguest is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                houseguest_id <- StreamData.member_of([1, 2, 3, 4, 5, 6]) do
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([houseguest_id])
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

    test "veto holder abstains from veto during a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

  @scorable_id 21
  describe "abstain from veto whilst on the block during a double eviction ceremony" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
                  ) do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

    test "is not a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

    test "houseguest is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                houseguest_id <- StreamData.member_of([1, 2, 3, 4, 5, 6]) do
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
            id: season_id,
            pov: 1,
            otb: MapSet.new([houseguest_id])
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

    test "veto holder abstains from veto during a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                remaining_events <- remaining_events_generator() do
        houseguest_id = 5

        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = nil

        curr = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            pov: houseguest_id,
            otb: MapSet.new([houseguest_id])
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

  @scorable_id 22
  describe "taken off the block in a standard eviction" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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

    test "is not a standard off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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

    test "nobody is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
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

    test "is a standard off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 23
  describe "taken off the block in a double eviction" do
    test "is not an off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 7)
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

    test "is not a double eviction off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.constant(1),
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

    test "nobody is taken off the block" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        event = %Event{
          event_type_id: event_type_id,
          houseguest_id: nil,
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

    test "is a double eviction off the block event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(7),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 24
  describe "standard replacement nomination" do
    test "is not a replacement nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 8)
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

    test "is not a standard replacement nomination" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(8),
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

    test "is a standard replacement nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(8),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 25
  describe "double eviction replacement nomination" do
    test "is not a nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 8)
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

    test "is a standard replacement nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(8),
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

    test "is a double eviction replacement nomination event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(8),
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
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
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
