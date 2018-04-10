defmodule FantasyBb.Core.Scoring.Scorable do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Team

  # Standard HoH
  def should_process(1, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 1 and is_standard_eviction(event) and not is_final_event(remaining, 1)
  end

  # Double Eviction HoH
  def should_process(2, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 1 and is_double_eviction(event) and not is_final_event(remaining, 1)
  end

  # Final HoH (Round 1)
  def should_process(3, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 2
  end

  # Final HoH (Round 2)
  def should_process(4, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 3
  end

  # Final HoH
  def should_process(5, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 1 and is_final_event(remaining, 1)
  end

  # Standard PoV
  def should_process(6, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_standard_eviction(event) and not is_final_event(remaining, 4)
  end

  # Double Eviction PoV
  def should_process(7, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_double_eviction(event) and not is_final_event(remaining, 4)
  end

  # Final PoV
  def should_process(8, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_final_event(remaining, 4)
  end

  # Standard Nomination
  def should_process(9, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 5 and is_standard_eviction(event)
  end

  # Double Eviction Nomination
  def should_process(10, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 5 and is_double_eviction(event)
  end

  # On the block
  def should_process(11, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 6
  end

  # Veto self
  def should_process(12, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and
      league.season.pov === event.houseguest_id
  end

  def should_process(_event_type_id, _events) do
    false
  end

  # Standard HoH
  def process(1, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double Eviction HoH
  def process(2, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Final HoH (Round 1)
  def process(3, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Final HoH (Round 2)
  def process(4, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Final HoH
  def process(5, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Standard PoV
  def process(6, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double Eviction PoV
  def process(7, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Final PoV
  def process(8, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Standard Nomination
  def process(9, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double Eviction Nomination
  def process(10, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double Eviction Nomination
  def process(11, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Veto self
  def process(12, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  def process(_event_type_id, _points, prev, curr) do
    {prev, curr}
  end

  defp is_final_event(events, event_type_id) do
    not_event_type = fn event ->
      Map.get(event, :event_type_id) !== event_type_id
    end

    Enum.all?(events, not_event_type)
  end

  defp is_standard_eviction(event) do
    event.order === 1
  end

  defp is_double_eviction(event) do
    event.order > 1
  end

  defp award_points_to_event_assignee(points, prev, curr) do
    league =
      hd(curr.events)
      |> Map.fetch!(:houseguest_id)
      |> add_points_for_houseguest(curr, points)

    {prev, league}
  end

  defp add_points_for_houseguest(houseguest_id, league, points) do
    update_team = fn team ->
      if Enum.member?(team.houseguests, houseguest_id) do
        %Team{team | points: team.points + points}
      else
        team
      end
    end

    put_in(league.teams, Enum.map(league.teams, update_team))
  end
end
