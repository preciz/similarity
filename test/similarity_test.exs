defmodule SimilarityTest do
  use ExUnit.Case
  doctest Similarity

  test "Cosine similarity" do
    assert Similarity.cosine([1,2], [1,2]) |> Float.round == 1

    assert Similarity.cosine([5,0], [0,5]) |> Float.round == 0

    assert Similarity.cosine([1,2], [-1,-2]) |> Float.round == -1
  end

  test "Euclidean dot product" do
    assert Similarity.dot_product([1], [1]) == 1

    assert Similarity.dot_product([11, 23, 41], [7,9,13]) == 817
  end

  test "Euclidean magnitude" do
    assert Similarity.magnitude([2]) == 2.0

    assert Similarity.magnitude([1,2]) == Similarity.magnitude([2,1])

    assert Similarity.magnitude([1,2]) |> Float.round(3) == 2.236
  end
end
