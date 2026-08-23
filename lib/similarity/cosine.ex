defmodule Similarity.Cosine do
  @moduledoc """
  A struct that can be used to accumulate ids & attributes and calculate similarity between them.
  """

  alias Similarity.Cosine

  defstruct attributes_counter: 0, attributes_map: %{}, map: %{}

  @doc """
  Returns a new `%Cosine{}` struct to be first used with `add/3` function
  """
  def new, do: %Cosine{}

  @doc """
  Puts a new id with attributes into `%Cosine{}.map` and returns `%Cosine{}` struct.

  ## Examples

      s = Similarity.Cosine.new
      s = s |> Similarity.Cosine.add("barna", [{"n_of_bacons", 3}, {"hair_color_r", 124}, {"hair_color_g", 188}, {"hair_color_b", 11}])

  """
  def add(struct = %Cosine{map: map}, id, attributes) do
    struct = %Cosine{attributes_map: attributes_map} = add_attributes(struct, attributes)

    transformed_attributes =
      attributes |> Enum.map(fn {key, value} -> {Map.get(attributes_map, key), value} end)

    new_map = map |> Map.put(id, transformed_attributes)

    %Cosine{struct | map: new_map}
  end

  @doc """
  Returns `Similarity.cosine_srol/2` similarity between two pairs of ids (id_a, id_b) in `%Cosine{}`.

  Returns `0.0` when the entries have no attributes in common. Raises `ArgumentError`
  when either ID is missing.

  ## Examples

      s = Similarity.Cosine.new
      s = s |> Similarity.Cosine.add("barna", [{"n_of_bacons", 3}, {"hair_color_r", 124}, {"hair_color_g", 188}, {"hair_color_b", 11}])
      s = s |> Similarity.Cosine.add("somebody", [{"n_of_bacons", 0}, {"hair_color_r", 222}, {"hair_color_g", 62}, {"hair_color_b", 11}])
      s |> Similarity.Cosine.between("barna", "somebody")

  """
  def between(%Cosine{map: map}, id_a, id_b) do
    do_between(map, id_a, id_b)
  end

  defp do_between(map, id_a, id_b) do
    attributes_a = fetch_attributes!(map, id_a)
    attributes_b = fetch_attributes!(map, id_b)

    values_b = index_attributes(attributes_b)

    {common_attributes_a, common_attributes_b} =
      attributes_a
      |> index_attributes()
      |> Enum.reduce({[], []}, fn {key, value_a}, {common_values_a, common_values_b} ->
        case Map.fetch(values_b, key) do
          {:ok, value_b} -> {[value_a | common_values_a], [value_b | common_values_b]}
          :error -> {common_values_a, common_values_b}
        end
      end)

    case common_attributes_a do
      [] -> 0.0
      _ -> Similarity.cosine_srol(common_attributes_a, common_attributes_b)
    end
  end

  # Reversing retains the first value for duplicate keys, matching Enum.find/2.
  defp index_attributes(attributes), do: attributes |> Enum.reverse() |> Map.new()

  defp fetch_attributes!(map, id) do
    case Map.fetch(map, id) do
      {:ok, attributes} -> attributes
      :error -> raise ArgumentError, "unknown cosine entry ID: #{inspect(id)}"
    end
  end

  @doc """
  Returns a stream of all unique pairs of similarities in `%Cosine{}.map`

  ## Examples

      s = Similarity.Cosine.new
      s = s |> Similarity.Cosine.add("barna", [{"n_of_bacons", 3}, {"hair_color_r", 124}, {"hair_color_g", 188}, {"hair_color_b", 11}])
      s = s |> Similarity.Cosine.add("somebody", [{"n_of_bacons", 0}, {"hair_color_r", 222}, {"hair_color_g", 62}, {"hair_color_b", 11}])
      Similarity.Cosine.stream(s)

  """
  def stream(%Cosine{map: map}) do
    Stream.resource(
      fn -> {Map.keys(map), map} end,
      &stream_next/1,
      fn _ -> :ok end
    )
  end

  defp stream_next({[], _map}) do
    {:halt, nil}
  end

  defp stream_next({[_last], _map}) do
    {:halt, nil}
  end

  defp stream_next({[left_id, right_id | remaining_ids], map}) do
    next_ids = [right_id | remaining_ids]

    {[{left_id, right_id, do_between(map, left_id, right_id)}],
     {left_id, remaining_ids, next_ids, map}}
  end

  defp stream_next({left_id, [right_id | remaining_ids], next_ids, map}) do
    {[{left_id, right_id, do_between(map, left_id, right_id)}],
     {left_id, remaining_ids, next_ids, map}}
  end

  defp stream_next({_left_id, [], next_ids, map}) do
    stream_next({next_ids, map})
  end

  @doc false
  def add_attributes(
        struct = %Cosine{attributes_counter: attributes_counter, attributes_map: attributes_map},
        attributes
      ) do
    {new_attributes_counter, new_attributes_map} =
      do_add_attributes(attributes, attributes_counter, attributes_map)

    %Cosine{
      struct
      | attributes_counter: new_attributes_counter,
        attributes_map: new_attributes_map
    }
  end

  defp do_add_attributes([], attributes_counter, attributes_map) do
    {attributes_counter, attributes_map}
  end

  defp do_add_attributes([{key, _value} | tl], attributes_counter, attributes_map) do
    if Map.has_key?(attributes_map, key) do
      do_add_attributes(tl, attributes_counter, attributes_map)
    else
      new_attributes_map = Map.put(attributes_map, key, attributes_counter)

      new_attributes_counter = attributes_counter + 1

      do_add_attributes(tl, new_attributes_counter, new_attributes_map)
    end
  end
end
