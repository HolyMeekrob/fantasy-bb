defmodule FantasyBb.Core.Utils.MapSet do
  def xor(%MapSet{} = a, %MapSet{} = b) do
    MapSet.union(
      MapSet.difference(a, b),
      MapSet.difference(b, a)
    )
  end
end
