defmodule Similarity.SimhashTest do
  use ExUnit.Case
  alias Similarity.Simhash

  doctest Simhash

  test "string shorter than ngram_size raises ArgumentError" do
    assert_raise ArgumentError, fn ->
      Simhash.similarity("a", "b", ngram_size: 2)
    end

    assert_raise ArgumentError, fn ->
      Simhash.hash("a", 2)
    end
  end

  test "similarity of identical strings is 1" do
    assert Simhash.similarity("aaa", "aaa") == 1

    assert Simhash.similarity("a", "a", ngram_size: 1) == 1
    assert Simhash.similarity("aa", "aa", ngram_size: 2) == 1
  end
end
