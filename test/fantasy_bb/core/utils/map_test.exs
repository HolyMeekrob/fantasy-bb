defmodule FantasyBb.Core.Utils.MapTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

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
    test "given a map" do
      check all input <- StreamData.map_of(StreamData.atom(:alphanumeric), StreamData.integer()) do
        func = fn x -> x + 1 end
        result = FantasyBb.Core.Utils.Map.map(input, func)

        assert(
          MapSet.equal?(
            MapSet.new(Map.keys(input)),
            MapSet.new(Map.keys(result))
          ),
          "the keys should be the same"
        )

        assert(
          Enum.all?(
            Map.keys(input),
            &(func.(Map.fetch!(input, &1)) === Map.fetch!(result, &1))
          ),
          "the values should equal the result of running the given function on each input value"
        )
      end
    end
  end
end
