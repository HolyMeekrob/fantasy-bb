defmodule FantasyBb.Core.League.LeagueState do
  alias FantasyBb.Core.Team
  alias FantasyBb.Data.Event
  alias FantasyBb.Data.EvictionVote
  alias FantasyBb.Data.League
  alias FantasyBb.Data.Season
  alias FantasyBb.Data.Trade

  @enforce_keys [:id, :name, :season]
  defstruct [:id, :name, :season, events: [], rules: [], teams: []]

  def init(%FantasyBb.Data.Schema.League{} = league) do
    season = League.get_season(league)
    teams = Enum.map(league.teams, &Team.initial_state/1)
    rules = League.get_rules(league)

    events = Event.for_scoring(season.id)
    trades = Trade.for_scoring(season.id)
    eviction_votes = EvictionVote.for_scoring(season.id)

    jury_votes = Season.get_jury_votes(season)

    all_events =
      Enum.concat([events, trades, eviction_votes])
      |> Enum.sort_by(&event_sort_value/1, &event_compare/2)
      |> Enum.concat(jury_votes)

    %FantasyBb.Core.League.LeagueState{
      id: league.id,
      name: league.name,
      season: FantasyBb.Core.Season.initial_state(season),
      events: all_events,
      teams: teams,
      rules: rules
    }
  end

  defp event_sort_value(%FantasyBb.Data.Schema.Event{} = event) do
    [
      event.eviction_ceremony.week.week_number,
      event.eviction_ceremony.order,
      1,
      event.inserted_at
    ]
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
    |> Enum.map(&compare/1)
    |> Enum.drop_while(&(&1 === :eq))
    |> Enum.at(0, :lt)
    |> is_less_than.()
  end

  defp compare({a, b}) when is_integer(a) and is_integer(b) do
    cond do
      a < b ->
        :lt

      a > b ->
        :gt

      true ->
        :eq
    end
  end

  defp compare({%NaiveDateTime{} = a, %NaiveDateTime{} = b}) do
    NaiveDateTime.compare(a, b)
  end

  def process(
        %FantasyBb.Data.Schema.Event{} = event,
        %FantasyBb.Core.League.LeagueState{} = league_state
      ) do
    league_state
  end

  def process(
        %FantasyBb.Data.Schema.Trade{} = trade,
        %FantasyBb.Core.League.LeagueState{} = league_state
      ) do
    league_state
  end

  def process(
        %FantasyBb.Data.Schema.EvictionVote{} = vote,
        %FantasyBb.Core.League.LeagueState{} = league_state
      ) do
    league_state
  end

  def process(
        %FantasyBb.Data.Schema.JuryVote{} = vote,
        %FantasyBb.Core.League.LeagueState{} = league_state
      ) do
    league_state
  end
end
