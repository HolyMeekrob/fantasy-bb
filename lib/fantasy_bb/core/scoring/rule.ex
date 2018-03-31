defmodule FantasyBb.Core.Scoring.Rule do
  import FantasyBb.Core.Utils.Enum, only: [last: 1]

  @enforce_keys [:scorable_id, :point_value]
  defstruct [:scorable_id, :point_value]

  defp create(%FantasyBb.Data.Schema.Rule{} = rule) do
    %FantasyBb.Core.Scoring.Rule{
      scorable_id: rule.scorable_id,
      point_value: rule.point_value
    }
  end

  defp create(%FantasyBb.Data.Schema.Scorable{} = scorable) do
    %FantasyBb.Core.Scoring.Rule{
      scorable_id: scorable.id,
      point_value: scorable.default_point_value
    }
  end

  def create_all(scorables, rules) do
    # This works because if there is a rule, it is the last value
    # Otherwise the scorable's default value is the last value
    get_last_point_value = fn {id, points} ->
      %FantasyBb.Core.Scoring.Rule{scorable_id: id, point_value: last(points)}
    end

    scorables
    |> Enum.concat(rules)
    |> Enum.map(&create/1)
    |> Enum.group_by(&Map.fetch!(&1, :scorable_id), &Map.fetch!(&1, :point_value))
    |> Enum.map(get_last_point_value)
  end
end
