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

  def process(event, league) do
    league
  end
end
