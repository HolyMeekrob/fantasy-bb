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

  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 1} = event, league) do
    hohs = [event.houseguest_id | league.season.hohs]
    put_in(league.season.hohs, hohs)
  end

  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 2} = event, league) do
    league
  end

  def process(%FantasyBb.Core.Scoring.Event{event_type_id: 3} = event, league) do
    league
  end

  def process(_, league) do
    league
  end
end
