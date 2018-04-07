defmodule FantasyBb.Core.Scoring.Scorable do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.Team

  # Standard HoH
  def should_process(1, %Event{} = event) do
    event.event_type_id === 1 and event.order === 1
  end

  # Double Eviction HoH
  def should_process(2, %Event{} = event) do
    event.event_type_id === 1 and event.order > 1
  end

  def should_process(_, _) do
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

  def process(_, _, prev, curr) do
    {prev, curr}
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
