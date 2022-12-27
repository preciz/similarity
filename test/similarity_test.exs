defmodule SimilarityTest do
  use ExUnit.Case
  doctest Similarity

  test "Cosine similarity" do
    assert Similarity.cosine([1, 2], [1, 2]) |> Float.round() == 1

    assert Similarity.cosine([5, 0], [0, 5]) |> Float.round() == 0

    assert Similarity.cosine([1, 2], [-1, -2]) |> Float.round() == -1
  end

  test "Euclidean dot product" do
    assert Similarity.dot_product([1], [1]) == 1

    assert Similarity.dot_product([11, 23, 41], [7, 9, 13]) == 817
  end

  test "Euclidean magnitude" do
    assert Similarity.magnitude([2]) == 2.0

    assert Similarity.magnitude([1, 2]) == Similarity.magnitude([2, 1])

    assert Similarity.magnitude([1, 2]) |> Float.round(3) == 2.236
  end

  test "Sorensen-Dice coefficient with strings" do
    assert Similarity.sorensen_dice("a", "a", ngram_size: 1) == 1.0
    assert Similarity.sorensen_dice("a", "b", ngram_size: 1) == 0.0
    assert Similarity.sorensen_dice("Just a few words", "Words just a few") == 0.6428571428571429
  end

  test "Sorensen-Dice coefficient with lists" do
    assert Similarity.sorensen_dice([1, 2, 3], [1, 2, 3]) == 1.0
    assert Similarity.sorensen_dice([1, 2, 3], [1, 2, 3, 4]) == 0.8571428571428571
  end

  test "Sorensen-Dice coefficient with MapSets" do
    assert Similarity.sorensen_dice(MapSet.new([1, 2, 3]), MapSet.new([1, 2, 3])) == 1.0

    assert Similarity.sorensen_dice(MapSet.new([1, 2, 3]), MapSet.new([1, 2, 3, 4])) ==
             0.8571428571428571
  end
end
