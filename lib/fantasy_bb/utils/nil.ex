defmodule FantasyBb.Core.Utils.Nil do
  def with_default(val, default) do
    if is_nil(val) do
      default
    else
      val
    end
  end
end
