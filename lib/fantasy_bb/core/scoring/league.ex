defmodule FantasyBb.Core.Scoring.League do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.JuryVote
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Season
  alias FantasyBb.Core.Scoring.Team
  alias FantasyBb.Core.Scoring.Trade
  alias FantasyBb.Data.League

  @enforce_keys [:season]
  defstruct [:season, events: [], rules: [], teams: []]

  def create(%FantasyBb.Data.Schema.League{} = league) do
    season = League.get_season(league)
    teams = Enum.map(league.teams, &Team.create/1)

    rules = Rule.create_all(FantasyBb.Data.Scorable.get_all(), League.get_rules(league))

    events =
      season.id
      |> FantasyBb.Data.Event.for_scoring()
      |> Event.create()

    trades =
      season.id
      |> FantasyBb.Data.Trade.for_scoring()
      |> Trade.create()

    eviction_votes =
      season.id
      |> FantasyBb.Data.EvictionVote.for_scoring()
      |> Enum.group_by(&Map.fetch!(&1, :eviction_ceremony_id))
      |> Enum.map(&EvictionCeremony.create(elem(&1, 1)))

    # TODO: Instead of individual jury votes, create a final ceremony
    # Similar to how eviction ceremonies are made up of eviction votes
    jury_votes =
      season
      |> FantasyBb.Data.Season.get_jury_votes()
      |> JuryVote.create()

    all_events =
      Enum.concat([events, trades, eviction_votes])
      |> Enum.sort_by(&event_sort_value/1, &event_compare/2)
      |> Enum.concat(jury_votes)

    %FantasyBb.Core.Scoring.League{
      season: Season.create(season),
      rules: rules,
      events: all_events,
      teams: teams
    }
  end

  defp event_sort_value(%Event{} = event) do
    [
      event.week_number,
      event.order,
      1,
      event.timestamp
    ]
  end

  defp event_sort_value(%Trade{} = trade) do
    [
      trade.week_number,
      0,
      0,
      trade.timestamp
    ]
  end

  defp event_sort_value(%EvictionCeremony{} = ceremony) do
    [
      ceremony.week_number,
      ceremony.order,
      2,
      ceremony.timestamp
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
end
