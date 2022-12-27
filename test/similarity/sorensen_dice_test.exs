defmodule Similarity.SorensenDiceTest do
  use ExUnit.Case
  doctest Similarity.SorensenDice

  test "raises ArgumentError when either string length is less than ngram_size" do
    assert_raise ArgumentError, fn ->
      Similarity.SorensenDice.sorensen_dice("a", "b", ngram_size: 2)
    end
  end
end
