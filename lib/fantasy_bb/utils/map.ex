defmodule FantasyBb.Core.Utils.Map do
  def string_keys_to_atoms(obj) do
    Enum.reduce(obj, Map.new(), &key_to_atom/2)
  end

  defp key_to_atom({key, val}, obj) when is_binary(key) do
    Map.put(obj, String.to_existing_atom(key), val)
  end

  defp key_to_atom({key, val}, obj) do
    Map.put(obj, key, val)
  end

  def map(obj, fun) do
    put = fn x, acc ->
      Map.put(acc, x, fun.(Map.fetch!(obj, x)))
    end

    Enum.reduce(Map.keys(obj), Map.new(), put)
  end
end
