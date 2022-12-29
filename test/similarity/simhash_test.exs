defmodule Similarity.SimhashTest do
  use ExUnit.Case
  alias Similarity.Simhash

  doctest Simhash

  test "string shorter than ngram_size raises ArgumentError" do
    assert_raise ArgumentError, fn ->
      Simhash.similarity("a", "b", ngram_size: 2)
    end

    assert_raise ArgumentError, fn ->
      Simhash.hash("a", ngram_size: 2)
    end
  end

  test "similarity of identical strings is 1" do
    assert Simhash.similarity("aaa", "aaa") == 1
    assert Simhash.similarity("aaa", "aaa", hash_function: :md5) == 1
    assert Simhash.similarity("aaa", "aaa", hash_function: :sha256) == 1

    assert Simhash.similarity("a", "a", ngram_size: 1) == 1
    assert Simhash.similarity("aa", "aa", ngram_size: 2) == 1
  end

  test "similarity of different strings" do
    assert Similarity.simhash("aaa", "bbb") == 0.53125
    assert Similarity.simhash("aaaa", "bbbb") == 0.53125

    assert Similarity.simhash("we spoke", "bespoke") == 0.703125
    assert Similarity.simhash("we spoke", "bespoke", hash_function: :md5) == 0.71875
    assert Similarity.simhash("we spoke", "bespoke", hash_function: :sha256) == 0.6796875
  end

  test "integer siphash of 1 char string is the same as simhash of it" do
    for char <- ["a", "b", "c", "d"] do
      assert Simhash.hash(char,
               ngram_size: 1,
               hash_function: :siphash,
               return_type: :int64_unsigned
             ) == SipHash.hash!("0123456789ABCDEF", char)
    end
  end

  test "binary siphash of char is the same as simhash of it" do
    for char <- ["a", "b", "c", "d"] do
      hash = SipHash.hash!("0123456789ABCDEF", char)

      assert Simhash.hash(char, ngram_size: 1, hash_function: :siphash, return_type: :binary) ==
               <<hash::64>>
    end
  end

  test "md5 hash of char is the same as simhash of it" do
    for char <- ["a", "b", "c", "d"] do
      assert Simhash.hash(char, ngram_size: 1, hash_function: :md5, return_type: :binary) ==
               :crypto.hash(:md5, char)
    end
  end

  test "sha256 hash of char is the same as simhash of it" do
    for char <- ["a", "b", "c", "d"] do
      assert Simhash.hash(char, ngram_size: 1, hash_function: :sha256, return_type: :binary) ==
               :crypto.hash(:sha256, char)
    end
  end
end
