defmodule FantasyBb.Core.EventTest do
  use ExUnit.Case, async: true
  use Quixir
  alias FantasyBb.Core.Scoring.Event

  test "hoh event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300)),
                  voters: list(of: int(min: 301, max: 400), min: 1),
                  evictees: list(of: int(min: 401))
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 1,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.hohs,
          Enum.into(league.season.hohs, MapSet.new())
        )

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      original_hohs = league.season.hohs
      result = Event.process(event, league)
      updated_hohs = result.season.hohs

      assert(
        Enum.count(updated_hohs) === Enum.count(original_hohs) + 1,
        "There should be one more HoH"
      )

      assert(
        Enum.any?(updated_hohs, &(&1 === event.houseguest_id)),
        "Event houseguest should be included in new HoHs"
      )

      assert(
        Enum.all?(original_hohs, &Enum.member?(updated_hohs, &1)),
        "All previous HoHs should still be present"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "New HoH should no longer be a voter"
      )
    end
  end

  test "final hoh round 1 event" do
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
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
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
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

  test "pov event" do
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 4,
        houseguest_id: houseguest_id,
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      result = Event.process(event, league)
      assert(Map.equal?(league, result), "should not change the league state")
    end
  end

  test "nomination event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300)),
                  voters: list(of: int(min: 301, max: 400), min: 1),
                  evictees: list(of: int(min: 401))
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 5,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.otb,
          Enum.into(league.season.otb, MapSet.new())
        )

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "There should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "Nominee should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "Everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "Nominee should no longer be a voter"
      )
    end
  end

  test "on the block event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300)),
                  voters: list(of: int(min: 301, max: 400), min: 1),
                  evictees: list(of: int(min: 401))
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 6,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.otb,
          Enum.into(league.season.otb, MapSet.new())
        )

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "There should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "Event houseguest should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "Everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "On the block houseguest should no longer be a voter"
      )
    end
  end

  test "off the block event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300), min: 1),
                  voters: list(of: int(min: 301, max: 400)),
                  evictees: list(of: int(min: 401))
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 7,
        houseguest_id: Enum.random(league.season.otb),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.otb,
          Enum.into(league.season.otb, MapSet.new())
        )

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      original_voters = league.season.voters
      result = Event.process(event, league)
      updated_voters = result.season.voters

      assert(
        Enum.count(updated_voters) === Enum.count(original_voters) + 1,
        "There should be one more voter"
      )

      assert(
        Enum.any?(updated_voters, &(&1 === event.houseguest_id)),
        "Event houseguest should be a voter"
      )

      assert(
        Enum.all?(original_voters, &Enum.member?(updated_voters, &1)),
        "All existing voters should still be there"
      )

      assert(
        not Enum.member?(result.season.otb, event.houseguest_id),
        "Event houseguest should no longer be on the block"
      )
    end
  end

  test "replacement nomination event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300)),
                  voters: list(of: int(min: 301, max: 400), min: 1),
                  evictees: list(of: int(min: 401))
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 8,
        houseguest_id: Enum.random(league.season.voters),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.otb,
          Enum.into(league.season.otb, MapSet.new())
        )

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      original_otb = league.season.otb
      result = Event.process(event, league)
      updated_otb = result.season.otb

      assert(
        Enum.count(updated_otb) === Enum.count(original_otb) + 1,
        "There should be one more on the block"
      )

      assert(
        Enum.any?(updated_otb, &(&1 === event.houseguest_id)),
        "Replacement nominee should be on the block"
      )

      assert(
        Enum.all?(original_otb, &Enum.member?(updated_otb, &1)),
        "Everyone already on the block should still be on the block"
      )

      assert(
        not Enum.member?(result.season.voters, event.houseguest_id),
        "Replacement nominee should no longer be a voter"
      )
    end
  end

  test "return to the house event" do
    ptest week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season:
                Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                  hohs: list(of: int(min: 101, max: 200)),
                  otb: list(of: int(min: 201, max: 300)),
                  voters: list(of: int(min: 301, max: 400)),
                  evictees: list(of: int(min: 401), min: 1)
                })
            }) do
      event = %FantasyBb.Core.Scoring.Event{
        event_type_id: 9,
        houseguest_id: Enum.random(league.season.evictees),
        week_number: week_number,
        order: order,
        timestamp: NaiveDateTime.utc_now()
      }

      league =
        put_in(
          league.season.voters,
          Enum.into(league.season.voters, MapSet.new())
        )

      league =
        put_in(
          league.season.evictees,
          Enum.into(league.season.evictees, MapSet.new())
        )

      original_voters = league.season.voters
      result = Event.process(event, league)
      updated_voters = result.season.voters

      assert(
        Enum.count(updated_voters) === Enum.count(original_voters) + 1,
        "There should be one more voter"
      )

      assert(
        Enum.any?(updated_voters, &(&1 === event.houseguest_id)),
        "Returned houseguest should be a voter"
      )

      assert(
        Enum.all?(original_voters, &Enum.member?(updated_voters, &1)),
        "All prior voters should still be voters"
      )

      assert(
        not Enum.member?(result.season.evictees, event.houseguest_id),
        "Returned houseguest should no longer be an evictee"
      )
    end
  end

  test "America's choice event" do
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
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
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
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
    ptest houseguest_id: positive_int(),
          week_number: positive_int(),
          order: positive_int(),
          league:
            Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
              season: FantasyBb.Core.Scoring.Season
            }) do
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
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200)),
                    otb: list(of: int(min: 201, max: 300)),
                    voters: list(of: int(min: 301, max: 400), min: 1),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.voters),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.voters, event.houseguest_id),
          "Evictee should no longer be a voter"
        )
      end
    end

    test "when houseguest is an hoh" do
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200), min: 1),
                    otb: list(of: int(min: 201, max: 300)),
                    voters: list(of: int(min: 301, max: 400)),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.hohs),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.hohs, event.houseguest_id),
          "Evictee should no longer be a Head of Household"
        )
      end
    end

    test "when houseguest is on the block" do
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200)),
                    otb: list(of: int(min: 201, max: 300), min: 1),
                    voters: list(of: int(min: 301, max: 400)),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 13,
          houseguest_id: Enum.random(league.season.otb),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.otb, event.houseguest_id),
          "Evictee should no longer be on the block"
        )
      end
    end
  end

  describe "Removal event" do
    test "when houseguest is a voter" do
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200)),
                    otb: list(of: int(min: 201, max: 300)),
                    voters: list(of: int(min: 301, max: 400), min: 1),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.voters),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.voters, event.houseguest_id),
          "Evictee should no longer be a voter"
        )
      end
    end

    test "when houseguest is an hoh" do
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200), min: 1),
                    otb: list(of: int(min: 201, max: 300)),
                    voters: list(of: int(min: 301, max: 400)),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.hohs),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.hohs, event.houseguest_id),
          "Evictee should no longer be a Head of Household"
        )
      end
    end

    test "when houseguest is on the block" do
      ptest week_number: positive_int(),
            order: positive_int(),
            league:
              Pollution.VG.struct(%FantasyBb.Core.Scoring.League{
                season:
                  Pollution.VG.struct(%FantasyBb.Core.Scoring.Season{
                    hohs: list(of: int(min: 101, max: 200)),
                    otb: list(of: int(min: 201, max: 300), min: 1),
                    voters: list(of: int(min: 301, max: 400)),
                    evictees: list(of: int(min: 401))
                  })
              }) do
        event = %FantasyBb.Core.Scoring.Event{
          event_type_id: 14,
          houseguest_id: Enum.random(league.season.otb),
          week_number: week_number,
          order: order,
          timestamp: NaiveDateTime.utc_now()
        }

        league =
          put_in(
            league.season.voters,
            Enum.into(league.season.voters, MapSet.new())
          )

        league =
          put_in(
            league.season.hohs,
            Enum.into(league.season.hohs, MapSet.new())
          )

        league =
          put_in(
            league.season.otb,
            Enum.into(league.season.otb, MapSet.new())
          )

        league =
          put_in(
            league.season.evictees,
            Enum.into(league.season.evictees, MapSet.new())
          )

        original_evictees = league.season.evictees
        result = Event.process(event, league)
        updated_evictees = result.season.evictees

        assert(
          Enum.count(updated_evictees) === Enum.count(original_evictees) + 1,
          "There should be one more evictee"
        )

        assert(
          Enum.any?(updated_evictees, &(&1 === event.houseguest_id)),
          "Houseguest should be an evictee"
        )

        assert(
          Enum.all?(original_evictees, &Enum.member?(updated_evictees, &1)),
          "All prior evictees should still be evicted"
        )

        assert(
          not Enum.member?(result.season.otb, event.houseguest_id),
          "Evictee should no longer be on the block"
        )
      end
    end
  end
end
