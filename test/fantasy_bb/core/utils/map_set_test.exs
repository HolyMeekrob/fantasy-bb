defmodule FantasyBb.Core.MapSetTest do
  use ExUnit.Case, async: true

  import FantasyBb.Core.Utils.MapSet, only: [xor: 2]

  describe "xor" do
    test "both sets are empty" do
      a = MapSet.new()
      b = MapSet.new()

      result = xor(a, b)

      assert(Enum.empty?(result), "result should be empty")
    end

    test "first set is empty" do
      a = MapSet.new()
      b = MapSet.new(["hello", "world"])

      result = xor(a, b)

      assert(
        MapSet.equal?(result, b),
        "result should equal non-empty set"
      )
    end

    test "second set is empty" do
      a = MapSet.new([1, 2, 3])
      b = MapSet.new()

      result = xor(a, b)

      assert(
        MapSet.equal?(result, a),
        "result should equal non-empty set"
      )
    end

    test "sets are the same" do
      a = MapSet.new([1, 2, 3])
      b = MapSet.new([1, 2, 3])

      result = xor(a, b)

      assert(Enum.empty?(result), "result should be empty")
    end

    test "sets have nothing in common" do
      a = MapSet.new([1, "two", 3])
      b = MapSet.new(["one", 2, "three"])

      result = xor(a, b)

      assert(
        Enum.all?(a, &MapSet.member?(result, &1)),
        "result should contain all elements of the first set"
      )

      assert(
        Enum.all?(b, &MapSet.member?(result, &1)),
        "result should contain all elements of the second set"
      )
    end

    test "sets have some things in common" do
      a = MapSet.new([1, "two", 3, "four"])
      b = MapSet.new(["two", "four", "six", "eight"])

      result = xor(a, b)

      assert(
        MapSet.equal?(result, MapSet.new([1, 3, "six", "eight"])),
        "result should contain only uncommon elements"
      )
    end
  end
end
