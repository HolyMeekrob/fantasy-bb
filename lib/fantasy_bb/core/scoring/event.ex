defmodule FantasyBb.Core.Scoring.Event do
  @enforce_keys [
    :event_type_id,
    :houseguest_id,
    :week_number,
    :order,
    :timestamp
  ]
  defstruct [
    :event_type_id,
    :houseguest_id,
    :week_number,
    :order,
    :timestamp
  ]

  def create(%FantasyBb.Data.Schema.Event{} = event) do
    %FantasyBb.Core.Scoring.Event{
      event_type_id: event.event_type_id,
      houseguest_id: event.houseguest_id,
      week_number: event.eviction_ceremony.week.week_number,
      order: event.eviction_ceremony.order,
      timestamp: event.inserted_at
    }
  end

  # HoH event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 1} = event, league) do
    hohs = MapSet.put(league.season.hohs, event.houseguest_id)
    voters = MapSet.delete(league.season.voters, event.houseguest_id)

    league = put_in(league.season.hohs, hohs)
    put_in(league.season.voters, voters)
  end

  # Final HoH (Round 1) event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 2} = event, league) do
    league
  end

  # Final HoH (Round 2) event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 3} = event, league) do
    league
  end

  # PoV event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 4} = event, league) do
    league
  end

  # Nomination event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 5} = event, league) do
    otb = MapSet.put(league.season.otb, event.houseguest_id)
    voters = MapSet.delete(league.season.voters, event.houseguest_id)

    league = put_in(league.season.otb, otb)
    put_in(league.season.voters, voters)
  end

  # On the block event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 6} = event, league) do
    otb = MapSet.put(league.season.otb, event.houseguest_id)
    voters = MapSet.delete(league.season.voters, event.houseguest_id)

    league = put_in(league.season.otb, otb)
    put_in(league.season.voters, voters)
  end

  # Off the block event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 7} = event, league) do
    voters = MapSet.put(league.season.voters, event.houseguest_id)
    otb = MapSet.delete(league.season.otb, event.houseguest_id)

    league = put_in(league.season.voters, voters)
    put_in(league.season.otb, otb)
  end

  # Replacement nomination event
  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 8} = event, league) do
    otb = MapSet.put(league.season.otb, event.houseguest_id)
    voters = MapSet.delete(league.season.voters, event.houseguest_id)

    league = put_in(league.season.otb, otb)
    put_in(league.season.voters, voters)
  end

  def process(_, league) do
    league
  end
end
