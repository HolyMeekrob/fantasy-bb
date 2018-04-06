defmodule FantasyBb.Core.Utils.NilTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import FantasyBb.Core.Utils.Nil

  describe "is_nil" do
    test "given nil" do
      check all default <- StreamData.term() do
        assert with_default(nil, default) === default
      end
    end

    test "given not-nil" do
      check all default <- StreamData.term(),
                val <- StreamData.term() do
        assert with_default(val, default) === val
      end
    end
  end
end
