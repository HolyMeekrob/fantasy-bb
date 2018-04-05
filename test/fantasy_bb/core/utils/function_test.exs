defmodule FantasyBb.Core.Utils.FunctionTest do
  use ExUnit.Case, async: true
  use Quixir

  import FantasyBb.Core.Utils.Function

  describe "identity" do
    test "given a value" do
      ptest val: any() do
        assert(identity(val) === val, "should return itself")
      end
    end
  end
end