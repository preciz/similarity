defmodule Similarity.Cosine do
  @moduledoc """
  A struct that can be used to accumulate ids & attributes and calcuate similarity between them.
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
  Returns `Similarity.cosine_srol/2` similarity between two pairs of ids (id_a, id_b) in `%Cosine{}`

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
    attributes_a = map |> Map.get(id_a)
    attributes_b = map |> Map.get(id_b)

    keys_a = attributes_a |> Enum.map(fn {k, _v} -> k end) |> MapSet.new()
    keys_b = attributes_b |> Enum.map(fn {k, _v} -> k end) |> MapSet.new()

    common_attributes_keys = MapSet.intersection(keys_a, keys_b)

    common_attributes_a =
      common_attributes_keys
      |> Enum.map(fn common_key ->
        Enum.find(attributes_a, fn {k, _v} -> k == common_key end) |> elem(1)
      end)

    common_attributes_b =
      common_attributes_keys
      |> Enum.map(fn common_key ->
        Enum.find(attributes_b, fn {k, _v} -> k == common_key end) |> elem(1)
      end)

    Similarity.cosine_srol(common_attributes_a, common_attributes_b)
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
      fn -> {_all_ids = Map.keys(map), map} end,
      &stream_next/1,
      fn _ -> nil end
    )
  end

  @doc false
  def stream_next({[_last | []], _map}) do
    {:halt, nil}
  end

  @doc false
  def stream_next({[h_id | tl_ids], map}) do
    {
      tl_ids |> Enum.map(fn id -> {h_id, id, do_between(map, h_id, id)} end),
      {tl_ids, map}
    }
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

  @doc false
  def do_add_attributes([], attributes_counter, attributes_map) do
    {attributes_counter, attributes_map}
  end

  @doc false
  def do_add_attributes([{key, _value} | tl], attributes_counter, attributes_map) do
    if Map.has_key?(attributes_map, key) do
      do_add_attributes(tl, attributes_counter, attributes_map)
    else
      new_attributes_map = Map.put(attributes_map, key, attributes_counter)

      new_attributes_counter = attributes_counter + 1

      do_add_attributes(tl, new_attributes_counter, new_attributes_map)
    end
  end
end
