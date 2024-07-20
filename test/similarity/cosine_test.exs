defmodule Similarity.CosineTest do
  use ExUnit.Case
  alias Similarity.Cosine

  test "add" do
    s = Cosine.new()

    s =
      s
      |> Cosine.add("barna", [
        {"n_of_bacons", 3},
        {"hair_color_r", 124},
        {"hair_color_g", 188},
        {"hair_color_b", 11}
      ])

    assert %Cosine{
             attributes_counter: 4,
             attributes_map: %{
               "hair_color_b" => 3,
               "hair_color_g" => 2,
               "hair_color_r" => 1,
               "n_of_bacons" => 0
             },
             map: %{"barna" => [{0, 3}, {1, 124}, {2, 188}, {3, 11}]}
           } = s
  end

  test "test between" do
    s = Cosine.new()

    s =
      s
      |> Cosine.add("barna", [
        {"n_of_bacons", 3},
        {"hair_color_r", 124},
        {"hair_color_g", 188},
        {"hair_color_b", 11}
      ])

    s =
      s
      |> Cosine.add("somebody", [
        {"n_of_bacons", 2},
        {"hair_color_r", 24},
        {"hair_color_g", 18},
        {"hair_color_b", 111}
      ])

    assert Cosine.between(s, "barna", "somebody") |> Float.round(3) == 0.585
  end

  test "new" do
    assert %Cosine{attributes_counter: 0, attributes_map: %{}, map: %{}} = Cosine.new()
  end

  test "add with empty attributes" do
    s = Cosine.new()
    s = Cosine.add(s, "empty", [])
    assert %Cosine{attributes_counter: 0, attributes_map: %{}, map: %{"empty" => []}} = s
  end

  test "between with identical entries" do
    s = Cosine.new()
    s = Cosine.add(s, "a", [{"attr", 1}])
    s = Cosine.add(s, "b", [{"attr", 1}])
    assert Cosine.between(s, "a", "b") == 1.0
  end

  test "stream" do
    s = Cosine.new()
    s = Cosine.add(s, "a", [{"attr", 1}])
    s = Cosine.add(s, "b", [{"attr", 2}])
    s = Cosine.add(s, "c", [{"attr", 3}])

    result = Cosine.stream(s) |> Enum.to_list()
    assert length(result) == 3
    assert Enum.all?(result, fn {_, _, similarity} -> is_float(similarity) end)
  end
end
