defmodule FantasyBb.Core.Utils.MapTest do
  use ExUnit.Case, async: true

  import FantasyBb.Core.Utils.Map

  describe "string_keys_to_atoms" do
    test "given an empty map" do
      result = string_keys_to_atoms(Map.new())

      assert(
        Map.equal?(result, Map.new()),
        "the result should be mepty"
      )
    end

    test "given a map with no string keys" do
      input = %{
        1 => "a",
        :b => 2,
        {"three"} => [3]
      }

      result = string_keys_to_atoms(input)

      assert(
        Map.equal?(result, input),
        "the map should not change"
      )
    end

    test "given a map with string keys" do
      input = %{
        key: "value",
        a: true
      }

      expected_output = %{
        key: "value",
        a: true
      }

      result = string_keys_to_atoms(input)

      assert(
        Map.equal?(result, expected_output),
        "the map should have string keys replaced by atoms"
      )
    end
  end

  describe "map" do
    test "given an empty map" do
      func = fn x -> x + 1 end
      input = Map.new()

      result = map(input, func)

      assert(
        Map.equal?(result, Map.new()),
        "the result should be empty"
      )
    end

    test "given a non-empty map" do
      input = %{
        a: -5,
        b: 0,
        c: 3,
        d: 104
      }

      func = fn x -> x + 1 end

      expected_output = %{
        a: -4,
        b: 1,
        c: 4,
        d: 105
      }

      result = map(input, func)

      assert(
        Map.equal?(result, expected_output),
        "the values should equal the result of running the given function on each input value"
      )
    end
  end
end
