defmodule FantasyBb.Core.Utils.Enum do
  def last(vals, default \\ nil) do
    vals
    |> Enum.reverse()
    |> Enum.at(0, default)
  end
end
