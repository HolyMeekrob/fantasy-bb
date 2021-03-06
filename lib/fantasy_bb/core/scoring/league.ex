defmodule FantasyBb.Core.Scoring.League do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.FinalCeremony
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Season
  alias FantasyBb.Core.Scoring.Team
  alias FantasyBb.Core.Scoring.Trade
  alias FantasyBb.Data.League

  @enforce_keys [:id, :season]
  defstruct [:id, :season, events: [], rules: [], teams: [], houseguests: Map.new()]

  def create(%FantasyBb.Data.Schema.League{} = league) do
    season = League.get_season(league)
    teams = Enum.map(league.teams, &Team.create/1)

    houseguests =
      Map.new(
        FantasyBb.Data.Season.get_houseguests(season),
        fn houseguest -> {houseguest.id, 0} end
      )

    rules =
      league
      |> League.get_rules()
      |> Enum.filter(&(Map.fetch!(&1, :point_value) !== 0))
      |> Enum.map(&Rule.create/1)

    events =
      season.id
      |> FantasyBb.Data.Event.for_scoring()
      |> Enum.map(&Event.create/1)

    trades =
      season.id
      |> FantasyBb.Data.Trade.for_scoring()
      |> Enum.map(&Trade.create/1)

    eviction_ceremonies =
      season.id
      |> FantasyBb.Data.EvictionCeremony.for_scoring()
      |> Enum.map(&EvictionCeremony.create/1)

    final_ceremony =
      season
      |> FantasyBb.Data.Season.get_jury_votes()
      |> FinalCeremony.create()

    all_events =
      Enum.concat([events, trades, eviction_ceremonies])
      |> Enum.sort_by(&event_sort_value/1, &event_compare/2)
      |> Enum.concat([final_ceremony])

    %FantasyBb.Core.Scoring.League{
      id: league.id,
      season: Season.create(season),
      rules: rules,
      events: all_events,
      teams: teams,
      houseguests: houseguests
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
