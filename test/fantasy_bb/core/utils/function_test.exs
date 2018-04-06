defmodule FantasyBb.Core.Utils.FunctionTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import FantasyBb.Core.Utils.Function

  describe "identity" do
    test "given a value" do
      check all val <- StreamData.term() do
        assert(identity(val) === val, "should return itself")
      end
    end
  end
end
