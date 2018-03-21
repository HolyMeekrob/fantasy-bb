defmodule FantasyBb.Core.League.LeagueState do
  alias FantasyBb.Core.Team

  @enforce_keys [:id]
  defstruct [:id, events: [], rules: [], teams: []]

  def init(%FantasyBb.Data.Schema.League{} = league) do
    events =
      league.season.houseguests
      |> Enum.flat_map(&Map.fetch!(&1, :events))

    trades =
      league.teams
      |> Enum.flat_map(&Map.fetch!(&1, :trades))
      |> Enum.filter(&Map.fetch!(&1, :is_approved))

    eviction_votes =
      league.season.weeks
      |> Enum.flat_map(&Map.fetch!(&1, :eviction_ceremonies))
      |> Enum.flat_map(&Map.fetch!(&1, :eviction_votes))

    jury_votes = league.season.jury_votes

    teams = Enum.map(league.teams, &Team.initial_state/2)

    all_events =
      Enum.concat([events, trades, eviction_votes])
      |> Enum.sort_by(&event_sort_value/1, &event_compare/2)
      |> Enum.concat(jury_votes)

    %FantasyBb.Core.League.LeagueState{
      id: league.id,
      events: all_events,
      teams: teams
    }
  end

  defp event_sort_value(%FantasyBb.Data.Schema.Event{} = event) do
    {
      event.eviction_ceremony.week.week_number,
      event.eviction_ceremony.order,
      1,
      event.inserted_at
    }
  end

  defp event_sort_value(%FantasyBb.Data.Schema.Trade{} = trade) do
    [
      trade.week.week_number,
      0,
      0,
      trade.updated_at
    ]
  end

  defp event_sort_value(%FantasyBb.Data.Schema.EvictionVote{} = vote) do
    [
      vote.eviction_ceremony.week.week_number,
      vote.eviction_ceremony.order,
      2,
      vote.inserted_at
    ]
  end

  defp event_compare(event_a, event_b) do
    is_less_than = fn val -> val === :lt end

    Enum.zip(event_a, event_b)
    |> Enum.map(&compare/2)
    |> Enum.drop_while(&(&1 === :eq))
    |> Enum.at(0, :lt)
    |> is_less_than.()
  end

  defp compare(a, b) when is_integer(a) and is_integer(b) do
    cond do
      a < b ->
        :lt

      a > b ->
        :gt

      true ->
        :eq
    end
  end

  defp compare(%Date{} = a, %Date{} = b) do
    Date.compare(a, b)
  end
end
