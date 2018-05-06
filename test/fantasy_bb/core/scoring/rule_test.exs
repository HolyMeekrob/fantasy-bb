defmodule FantasyBb.Core.Scoring.RuleTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.EvictionVote
  alias FantasyBb.Core.Scoring.FinalCeremony
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

    test "is a self-veto" do
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

    test "is a self veto" do
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

  @scorable_id 26
  describe "dodge standard eviction" do
    test "is not a standard eviction" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a standard eviction and all evictees on one team" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end

    test "is a standard eviction and evictees on different teams" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6, 12]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7, 12])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7, 12]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end
  end

  @scorable_id 27
  describe "dodge double eviction" do
    test "is not a double eviction" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a double eviction and all evictees on one team" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end

    test "is a standard event and evictees on different teams" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 6, 12]),
            hohs: MapSet.new([7]),
            evictees: MapSet.new([10, 11])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 7, 12])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([10, 11, 2]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 6, 7, 12]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end
  end

  @scorable_id 28
  describe "vote for evicted houseguest" do
    test "all votes come from the same team" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value * 2)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "votes come from different teams" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 4, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 3]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 29
  describe "vote for non-evicted houseguest" do
    test "all votes come from the same team" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end

    test "votes come from different teams" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 4, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4},
            %EvictionVote{voter_id: 8, candidate_id: 4},
            %EvictionVote{voter_id: 9, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 3]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 8])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7, 9])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7, 8, 9]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 30
  describe "sole vote against the house" do
    test "votes are unanimous" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "multiple votes for each candidate" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4},
            %EvictionVote{voter_id: 8, candidate_id: 4},
            %EvictionVote{voter_id: 5, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 8])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7, 8]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "multiple candidates received a single vote" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4},
            %EvictionVote{voter_id: 8, candidate_id: 9}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4, 9]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 8])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7, 9])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7, 8, 9]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "only one vote" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 3]),
            hohs: MapSet.new([1]),
            evictees: MapSet.new([4])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([3, 4])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 4]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "two votes with hoh tiebreaker" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 5, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([1, 6]),
            voters: MapSet.new([3, 7])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "sole vote against the house" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5, 6, 7])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5, 7]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 31
  describe "return to the house" do
    test "is not a return to the house event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 9)
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

    test "is a return to the house event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(9),
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

  @scorable_id 32
  describe "win america's choice" do
    test "is not an america's choice event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 10)
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

    test "is an america's choice event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(10),
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

  @scorable_id 33
  describe "survive the week" do
    test "not the end of a week" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        next_event = %Event{
          event_type_id: 1,
          houseguest_id: 1,
          week_number: week_number,
          order: order - 1,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([8]),
            evictees: MapSet.new([9, 10])
          },
          events: [ceremony | [next_event | remaining_events]],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 4, 5])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([6, 7, 8, 9, 10])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([4, 9, 10]))
        curr = put_in(curr.season.voters, MapSet.new([1, 2, 3, 5, 6, 7, 8]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "eviction ceremony with survivors that concludes the week" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        next_event = %Event{
          event_type_id: 1,
          houseguest_id: 1,
          week_number: week_number + 1,
          order: 1,
          timestamp: NaiveDateTime.utc_now()
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([8]),
            evictees: MapSet.new([9, 10])
          },
          events: [ceremony | [next_event | remaining_events]],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 4, 5])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([6, 7, 8, 9, 10])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([4, 9, 10]))
        curr = put_in(curr.season.voters, MapSet.new([1, 2, 3, 5, 6, 7, 8]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value * 4)
        assert_team_has_points(result, 2, 20 + point_value * 3)
      end
    end
  end

  @scorable_id 34
  describe "win miscellaneous competition" do
    test "is not a miscellaneous competition event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 11)
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

    test "is a miscellaneous competition event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(11),
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

  @scorable_id 35
  describe "win Big Brother" do
    test "unanimous vote" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end

    test "split vote" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 4},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 36
  describe "finish Big Brother in second place" do
    test "unanimous vote" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end

    test "split vote" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 4},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 37
  describe "finish Big Brother in third place" do
    test "eviction ceremony with at least four people left in the house" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([8]),
            evictees: MapSet.new([9, 10])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 4, 5])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([6, 7, 8, 9, 10])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([4, 9, 10]))
        curr = put_in(curr.season.voters, MapSet.new([1, 2, 3, 5, 6, 7, 8]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "eviction ceremony with three people left in the house" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([3]),
            evictees: MapSet.new([5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 5]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "eviction ceremony with two people left in the house" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            voters: MapSet.new([2, 3]),
            hohs: MapSet.new([1]),
            evictees: MapSet.new([4, 5, 6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 4, 5, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 38
  describe "win america's favorite player" do
    test "is not an america's favorite player event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 12)
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

    test "is an america's favorite player event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(12),
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

  @scorable_id 39
  describe "self-evict" do
    test "is not a self-eviction event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 13)
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

    test "is a self-eviction event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(13),
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

  @scorable_id 40
  describe "removed from the house" do
    test "is not a removed from the house event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator(),
                event_type_id <-
                  StreamData.filter(
                    StreamData.positive_integer(),
                    &(&1 !== 14)
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

    test "is a removed from the house event" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                event_type_id <- StreamData.constant(14),
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

  @scorable_id 41
  describe "evicted during a standard eviction ceremony" do
    test "is a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 42
  describe "evicted during a double eviction ceremony" do
    test "is a standard eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.constant(1),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert(curr === result, "updated league state should not change")
      end
    end

    test "is a double eviction ceremony" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.map(StreamData.positive_integer(), &(&1 + 1)),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([5]),
            evictees: MapSet.new([6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([2, 6]))
        curr = put_in(curr.season.voters, MapSet.new([1, 3, 4, 5]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20)
      end
    end
  end

  @scorable_id 43
  describe "made jury" do
    test "final ceremony" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 4},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([4, 5])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value * 2)
        assert_team_has_points(result, 2, 20 + point_value)
      end
    end
  end

  @scorable_id 44
  describe "vote for the winner" do
    test "final ceremony" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 4},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5, 6])
          },
          events: [ceremony | remaining_events],
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

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end
  end

  @scorable_id 45
  describe "vote for the loser" do
    test "final ceremony" do
      check all point_value <- StreamData.integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %FinalCeremony{
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 4},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4},
            %EvictionVote{voter_id: 7, candidate_id: 2},
            %EvictionVote{voter_id: 8, candidate_id: 4},
            %EvictionVote{voter_id: 9, candidate_id: 2}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new(),
            hohs: MapSet.new(),
            voters: MapSet.new([2, 4]),
            evictees: MapSet.new([1, 3, 5, 6])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 4])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([5, 6, 7, 8, 9])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([1, 2, 3]))
        curr = put_in(curr.season.voters, MapSet.new())

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value)
        assert_team_has_points(result, 2, 20 + point_value * 2)
      end
    end
  end

  @scorable_id 46
  describe "survive eviction" do
    test "eviction ceremony with survivors" do
      check all point_value <- StreamData.integer(),
                week_number <- StreamData.positive_integer(),
                order <- StreamData.positive_integer(),
                league_id <- StreamData.positive_integer(),
                season_id <- StreamData.positive_integer(),
                remaining_events <- remaining_events_generator() do
        rule = %Rule{
          scorable_id: @scorable_id,
          point_value: point_value
        }

        ceremony = %EvictionCeremony{
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now(),
          votes: [
            %EvictionVote{voter_id: 1, candidate_id: 2},
            %EvictionVote{voter_id: 3, candidate_id: 2},
            %EvictionVote{voter_id: 5, candidate_id: 4},
            %EvictionVote{voter_id: 6, candidate_id: 4},
            %EvictionVote{voter_id: 7, candidate_id: 4}
          ]
        }

        prev_a = %League{
          id: league_id,
          season: %Season{
            id: season_id,
            otb: MapSet.new([2, 4]),
            hohs: MapSet.new([8]),
            evictees: MapSet.new([9, 10])
          },
          events: [ceremony | remaining_events],
          teams: [
            %Team{
              id: 1,
              points: 10,
              houseguests: MapSet.new([1, 2, 3, 4, 5])
            },
            %Team{
              id: 2,
              points: 20,
              houseguests: MapSet.new([6, 7, 8, 9, 10])
            }
          ]
        }

        curr = put_in(prev_a.season.otb, MapSet.new())
        curr = put_in(curr.season.hohs, MapSet.new())
        curr = put_in(curr.season.evictees, MapSet.new([4, 9, 10]))
        curr = put_in(curr.season.voters, MapSet.new([1, 2, 3, 5, 6, 7, 8]))

        {prev_b, result} = Rule.process(rule, {prev_a, curr})

        assert(prev_a === prev_b, "prior league state should not change")
        assert_team_has_points(result, 1, 10 + point_value * 4)
        assert_team_has_points(result, 2, 20 + point_value * 3)
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
