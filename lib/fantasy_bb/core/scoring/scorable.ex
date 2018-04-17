defmodule FantasyBb.Core.Scoring.Scorable do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.FinalCeremony
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

  # Vote for evicted houseguest
  def should_process(28, %League{events: [%EvictionCeremony{} | _remaining]}) do
    true
  end

  # Vote for non-evicted houseguest
  def should_process(29, %League{events: [%EvictionCeremony{} | _remaining]}) do
    true
  end

  # Sole vote against the house
  def should_process(30, %League{events: [%EvictionCeremony{} | _remaining]}) do
    true
  end

  # Return to the house
  def should_process(31, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 9
  end

  # Win America's choice
  def should_process(32, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 10
  end

  # Survive the week
  def should_process(33, %League{events: [%EvictionCeremony{} | _remaining]}) do
    true
  end

  # Win miscellaneous competition
  def should_process(34, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 11
  end

  # Win Big Brother
  def should_process(35, %League{events: [%FinalCeremony{} | _remaining]}) do
    true
  end

  # Finish in second place
  def should_process(36, %League{events: [%FinalCeremony{} | _remaining]}) do
    true
  end

  # Finish in third place
  def should_process(37, %League{events: [%EvictionCeremony{} | _remaining]} = league) do
    Enum.count(league.season.voters) === 2
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

  # Vote for evicted houseguest
  def process(28, points, prev, curr) do
    add_points = fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end

    evictee =
      curr.season.evictees
      |> MapSet.difference(prev.season.evictees)
      |> Enum.at(0)

    league =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) === evictee))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> Enum.reduce(curr, add_points)

    {prev, league}
  end

  # Vote for non-evicted houseguest
  def process(29, points, prev, curr) do
    add_points = fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end

    evictee =
      curr.season.evictees
      |> MapSet.difference(prev.season.evictees)
      |> Enum.at(0)

    league =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) !== evictee))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> Enum.reduce(curr, add_points)

    {prev, league}
  end

  # Sole vote against the house
  def process(30, points, prev, curr) do
    has_one_vote = fn {_candidate_id, votes} ->
      Enum.count(votes) === 1
    end

    grouped_votes =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.group_by(&Map.fetch!(&1, :candidate_id))

    sole_vote = Enum.count(grouped_votes) === 2 and Enum.any?(grouped_votes, has_one_vote)

    if(sole_vote) do
      houseguest_id =
        grouped_votes
        |> Enum.find(has_one_vote)
        |> elem(1)
        |> hd()
        |> Map.fetch!(:voter_id)

      league = add_points_for_houseguest(houseguest_id, curr, points)
      {prev, league}
    else
      {prev, curr}
    end
  end

  # Return to the house
  def process(31, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Win America's choice
  def process(32, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Survive the week
  def process(33, points, prev, curr) do
    add_points = fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end

    league = Enum.reduce(curr.season.voters, curr, add_points)

    {prev, league}
  end

  # Win miscellaneous competition
  def process(34, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Win Big Brother
  def process(35, points, prev, curr) do
    winner =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.group_by(&Map.fetch!(&1, :candidate_id))
      |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
      |> Enum.sort_by(fn {_id, votes} -> votes end, &>/2)
      |> List.first()
      |> elem(0)

    league = add_points_for_houseguest(winner, curr, points)
    {prev, league}
  end

  # Finish in second place
  def process(36, points, prev, curr) do
    groups =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.group_by(&Map.fetch!(&1, :candidate_id))

    groups =
      Enum.reduce(prev.season.voters, groups, fn candidate, map ->
        Map.put_new(map, candidate, [])
      end)

    loser =
      groups
      |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
      |> Enum.sort_by(fn {_id, votes} -> votes end, &</2)
      |> List.first()
      |> elem(0)

    league = add_points_for_houseguest(loser, curr, points)
    {prev, league}
  end

  # Finish in third place
  def process(37, points, prev, curr) do
    houseguest =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> hd()
      |> Map.fetch!(:candidate_id)

    league = add_points_for_houseguest(houseguest, curr, points)
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
