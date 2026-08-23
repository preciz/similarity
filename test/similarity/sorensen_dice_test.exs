defmodule Similarity.SorensenDiceTest do
  use ExUnit.Case
  doctest Similarity.SorensenDice

  test "raises ArgumentError when either string length is less than ngram_size" do
    assert_raise ArgumentError, fn ->
      Similarity.SorensenDice.sorensen_dice("a", "b", ngram_size: 2)
    end

    assert_raise ArgumentError, fn ->
      Similarity.SorensenDice.sorensen_dice("a", "a", ngram_size: 2)
    end
  end

  test "ngram_size must be a positive integer" do
    for ngram_size <- [0, -1, 1.5, "3", nil, false] do
      assert_raise ArgumentError, ~r/ngram_size must be a positive integer/, fn ->
        Similarity.SorensenDice.sorensen_dice("abc", "def", ngram_size: ngram_size)
      end
    end
  end
end
