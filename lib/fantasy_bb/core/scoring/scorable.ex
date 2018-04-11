defmodule FantasyBb.Core.Scoring.Scorable do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Team

  # Standard eviction HoH
  def should_process(1, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 1 and is_standard_eviction(event) and not is_final_event(remaining, 1)
  end

  # Double eviction HoH
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

  # Standard eviction PoV
  def should_process(6, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_standard_eviction(event) and not is_final_event(remaining, 4)
  end

  # Double eviction PoV
  def should_process(7, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_double_eviction(event) and not is_final_event(remaining, 4)
  end

  # Final PoV
  def should_process(8, %League{events: [%Event{} = event | remaining]}) do
    event.event_type_id === 4 and is_final_event(remaining, 4)
  end

  # Standard nomination
  def should_process(9, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 5 and is_standard_eviction(event)
  end

  # Double eviction nomination
  def should_process(10, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 5 and is_double_eviction(event)
  end

  # On the block
  def should_process(11, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 6
  end

  # Veto self - standard eviction
  def should_process(12, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and
      league.season.pov === event.houseguest_id
  end

  # Veto self - double eviction
  def should_process(13, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and
      league.season.pov === event.houseguest_id
  end

  # Veto another whilst not on the block - standard eviction
  def should_process(14, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and
      league.season.pov !== event.houseguest_id and
      not MapSet.member?(league.season.otb, league.season.pov)
  end

  # Veto another whilst not on the block - double eviction
  def should_process(15, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and
      league.season.pov !== event.houseguest_id and
      not MapSet.member?(league.season.otb, league.season.pov)
  end

  # Veto another whilst on the block - standard eviction
  def should_process(16, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and
      league.season.pov !== event.houseguest_id and
      MapSet.member?(league.season.otb, league.season.pov)
  end

  # Veto another whilst on the block - double eviction
  def should_process(17, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and
      league.season.pov !== event.houseguest_id and
      MapSet.member?(league.season.otb, league.season.pov)
  end

  # Abstain from veto whilst not on the block - standard eviction
  def should_process(18, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and is_nil(event.houseguest_id) and
      not MapSet.member?(league.season.otb, league.season.pov)
  end

  # Abstain from veto whilst not on the block - double eviction
  def should_process(19, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and is_nil(event.houseguest_id) and
      not MapSet.member?(league.season.otb, league.season.pov)
  end

  # Abstain from veto whilst on the block - standard eviction
  def should_process(20, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and is_nil(event.houseguest_id) and
      MapSet.member?(league.season.otb, league.season.pov)
  end

  # Abstain from veto whilst on the block - double eviction
  def should_process(21, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and is_nil(event.houseguest_id) and
      MapSet.member?(league.season.otb, league.season.pov)
  end

  # Taken off the block - standard eviction
  def should_process(22, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 7 and is_standard_eviction(event) and not is_nil(event.houseguest_id)
  end

  # Taken off the block - double eviction
  def should_process(23, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 7 and is_double_eviction(event) and not is_nil(event.houseguest_id)
  end

  # Standard replacement nomination
  def should_process(24, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 8 and is_standard_eviction(event)
  end

  # Double eviction replacement nomination
  def should_process(25, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 8 and is_double_eviction(event)
  end

  # Dodge eviction - standard eviction
  def should_process(26, %League{events: [%EvictionCeremony{} = ceremony | _remaining]}) do
    is_standard_eviction(ceremony)
  end

  # Dodge eviction - double eviction
  def should_process(27, %League{events: [%EvictionCeremony{} = ceremony | _remaining]}) do
    is_double_eviction(ceremony)
  end

  def should_process(_event_type_id, _events) do
    false
  end

  # Standard evction HoH
  def process(1, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double eviction HoH
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

  # Standard eviction PoV
  def process(6, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double eviction PoV
  def process(7, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Final PoV
  def process(8, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Standard nomination
  def process(9, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double eviction nomination
  def process(10, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # On the block
  def process(11, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Veto self - standard eviction
  def process(12, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Veto self - double eviction
  def process(13, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Veto another whilst not on the block - standard eviction
  def process(14, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Veto another whilst not on the block - double eviction
  def process(15, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Veto another whilst not on the block - standard eviction
  def process(16, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Veto another whilst not on the block - double eviction
  def process(17, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Abstain from veto whilst not on the block - standard eviction
  def process(18, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Abstain from veto whilst not on the block - double eviction
  def process(19, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Abstain from veto whilst on the block - standard eviction
  def process(20, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Abstain from veto whilst on the block - double eviction
  def process(21, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Taken off the block - standard eviction
  def process(22, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Taken off the block - double eviction
  def process(23, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Standard replacement nomination
  def process(24, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Double eviction replacement nomination
  def process(25, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Dodge eviction - standard eviction
  def process(26, points, prev, curr) do
    add_points = fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end

    league =
      prev.season.otb
      |> MapSet.difference(curr.season.evictees)
      |> Enum.reduce(curr, add_points)

    {prev, league}
  end

  # Dodge eviction - double eviction
  def process(27, points, prev, curr) do
    add_points = fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end

    league =
      prev.season.otb
      |> MapSet.difference(curr.season.evictees)
      |> Enum.reduce(curr, add_points)

    {prev, league}
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
