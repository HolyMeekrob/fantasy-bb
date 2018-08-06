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
  def should_process(22, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_standard_eviction(event) and not is_nil(event.houseguest_id) and
      league.season.pov !== event.houseguest_id
  end

  # Taken off the block - double eviction
  def should_process(23, %League{events: [%Event{} = event | _remaining]} = league) do
    event.event_type_id === 7 and is_double_eviction(event) and not is_nil(event.houseguest_id) and
      league.season.pov !== event.houseguest_id
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
    is_standard_eviction(ceremony) and Enum.any?(ceremony.votes)
  end

  # Dodge eviction - double eviction
  def should_process(27, %League{events: [%EvictionCeremony{} = ceremony | _remaining]}) do
    is_double_eviction(ceremony) and Enum.any?(ceremony.votes)
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
  def should_process(33, %League{events: [current | [next | _remaining]]}) do
    has_week_number? = fn event -> Map.has_key?(event, :week_number) end
    get_week_number = fn event -> Map.fetch!(event, :week_number) end

    has_week_number?.(current) and has_week_number?.(next) and
      get_week_number.(current) < get_week_number.(next)
  end

  # Win miscellaneous competition
  def should_process(34, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 11
  end

  # Win Big Brother
  def should_process(35, %League{events: [%FinalCeremony{} = ceremony | _remaining]}) do
    Enum.any?(ceremony.votes)
  end

  # Finish in second place
  def should_process(36, %League{events: [%FinalCeremony{} = ceremony | _remaining]}) do
    Enum.any?(ceremony.votes)
  end

  # Finish in third place
  def should_process(37, %League{events: [%EvictionCeremony{} | _remaining]} = league) do
    Enum.count(league.season.voters) === 2
  end

  # Win America's favorite player
  def should_process(38, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 12
  end

  # Self-evict
  def should_process(39, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 13
  end

  # Removed from the house
  def should_process(40, %League{events: [%Event{} = event | _remaining]}) do
    event.event_type_id === 14
  end

  # Evicted - standard eviction
  def should_process(41, %League{events: [%EvictionCeremony{} = ceremony | _remaining]}) do
    is_standard_eviction(ceremony)
  end

  # Evicted - double eviction
  def should_process(42, %League{events: [%EvictionCeremony{} = ceremony | _remaining]}) do
    is_double_eviction(ceremony)
  end

  # Made jury
  def should_process(43, %League{events: [%FinalCeremony{} = ceremony | _remaining]}) do
    Enum.any?(ceremony.votes)
  end

  # Vote for winner
  def should_process(44, %League{events: [%FinalCeremony{} | _remaining]}) do
    true
  end

  # Vote for loser
  def should_process(45, %League{events: [%FinalCeremony{} | _remaining]}) do
    true
  end

  # Survive eviction
  def should_process(46, %League{events: [%EvictionCeremony{} | _remaining]}) do
    true
  end

  def should_process(_event_type_id, _events) do
    false
  end

  # Standard eviction HoH
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

  # Veto another whilst on the block - standard eviction
  def process(16, points, prev, curr) do
    league = add_points_for_houseguest(curr.season.pov, curr, points)
    {prev, league}
  end

  # Veto another whilst on the block - double eviction
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
    league =
      prev.season.otb
      |> MapSet.difference(curr.season.evictees)
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Dodge eviction - double eviction
  def process(27, points, prev, curr) do
    league =
      prev.season.otb
      |> MapSet.difference(curr.season.evictees)
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Vote for evicted houseguest
  def process(28, points, prev, curr) do
    evictee = get_evictee(prev, curr)

    league =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) === evictee))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Vote for non-evicted houseguest
  def process(29, points, prev, curr) do
    evictee = get_evictee(prev, curr)

    league =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) !== evictee))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Sole vote against the house
  def process(30, points, prev, curr) do
    has_one_vote = fn {_candidate_id, votes} ->
      Enum.count(votes) === 1
    end

    voter_is_not_hoh = fn voter ->
      not Enum.member?(prev.season.hohs, Map.fetch!(voter, :voter_id))
    end

    votes =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.filter(voter_is_not_hoh)

    grouped_votes = Enum.group_by(votes, &Map.fetch!(&1, :candidate_id))

    sole_vote =
      Enum.count(votes) > 2 and Enum.count(grouped_votes) === 2 and
        Enum.any?(grouped_votes, has_one_vote)

    if sole_vote do
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
    league = Enum.reduce(curr.season.voters, curr, add_points(points))

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
      |> get_winner()

    league = add_points_for_houseguest(winner, curr, points)
    {prev, league}
  end

  # Finish in second place
  def process(36, points, prev, curr) do
    loser =
      curr.events
      |> hd()
      |> get_loser(prev.season.voters)

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

  # Win America's favorite player
  def process(38, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Self evict
  def process(39, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Removed from the house
  def process(40, points, prev, curr) do
    award_points_to_event_assignee(points, prev, curr)
  end

  # Evicted - standard eviction
  def process(41, points, prev, curr) do
    evictee = get_evictee(prev, curr)
    league = add_points_for_houseguest(evictee, curr, points)

    {prev, league}
  end

  # Evicted - double eviction
  def process(42, points, prev, curr) do
    evictee = get_evictee(prev, curr)
    league = add_points_for_houseguest(evictee, curr, points)

    {prev, league}
  end

  # Made jury
  def process(43, points, prev, curr) do
    league =
      curr.events
      |> hd()
      |> Map.fetch!(:votes)
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> MapSet.new()
      |> MapSet.union(prev.season.voters)
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Vote for winner
  def process(44, points, prev, curr) do
    ceremony = hd(curr.events)
    winner = get_winner(ceremony)

    league =
      Map.fetch!(ceremony, :votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) === winner))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> MapSet.new()
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Vote for loser
  def process(45, points, prev, curr) do
    ceremony = hd(curr.events)
    loser = get_loser(ceremony, prev.season.voters)

    league =
      Map.fetch!(ceremony, :votes)
      |> Enum.filter(&(Map.fetch!(&1, :candidate_id) === loser))
      |> Enum.map(&Map.fetch!(&1, :voter_id))
      |> MapSet.new()
      |> Enum.reduce(curr, add_points(points))

    {prev, league}
  end

  # Survive eviction
  def process(46, points, prev, curr) do
    league = Enum.reduce(curr.season.voters, curr, add_points(points))

    {prev, league}
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

    league = put_in(league.teams, Enum.map(league.teams, update_team))

    put_in(
      league.houseguests,
      Map.update(league.houseguests, houseguest_id, points, &(&1 + points))
    )
  end

  defp add_points(points) do
    fn houseguest, league ->
      add_points_for_houseguest(houseguest, league, points)
    end
  end

  defp get_evictee(prev, curr) do
    curr.season.evictees
    |> MapSet.difference(prev.season.evictees)
    |> Enum.at(0)
  end

  defp get_winner(%FinalCeremony{votes: votes}) do
    votes
    |> Enum.group_by(&Map.fetch!(&1, :candidate_id))
    |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
    |> Enum.sort_by(fn {_id, vote_count} -> vote_count end, &>/2)
    |> List.first()
    |> elem(0)
  end

  defp get_loser(%FinalCeremony{votes: votes}, finalists) do
    groups = Enum.group_by(votes, &Map.fetch!(&1, :candidate_id))

    add_if_missing = fn candidate, map ->
      Map.put_new(map, candidate, [])
    end

    groups = Enum.reduce(finalists, groups, add_if_missing)

    groups
    |> FantasyBb.Core.Utils.Map.map(&Enum.count/1)
    |> Enum.sort_by(fn {_id, vote_count} -> vote_count end, &</2)
    |> List.first()
    |> elem(0)
  end
end
