defmodule FantasyBb.Core.Utils.NilTest do
  use ExUnit.Case, async: true
  use Quixir

  import FantasyBb.Core.Utils.Nil

  describe "is_nil" do
    test "given nil" do
      ptest default: any() do
        assert with_default(nil, default) === default
      end
    end

    test "given not-nil" do
      ptest default: any(), val: any() do
        assert with_default(val, default) === val
      end
    end
  end
end
