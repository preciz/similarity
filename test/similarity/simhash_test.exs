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

  test "unsupported hash function raises ArgumentError" do
    for hash_function <- [:unsupported, nil, false] do
      assert_raise ArgumentError, ~r/hash_function must be one of/, fn ->
        Simhash.similarity("abc", "def", hash_function: hash_function)
      end

      assert_raise ArgumentError, ~r/hash_function must be one of/, fn ->
        Simhash.hash("abc", hash_function: hash_function)
      end
    end
  end

  test "ngram_size must be a positive integer" do
    for ngram_size <- [0, -1, 1.5, "3", nil, false] do
      assert_raise ArgumentError, ~r/ngram_size must be a positive integer/, fn ->
        Simhash.hash("abc", ngram_size: ngram_size)
      end

      assert_raise ArgumentError, ~r/ngram_size must be a positive integer/, fn ->
        Simhash.similarity("abc", "def", ngram_size: ngram_size)
      end
    end
  end

  test "return_type must be supported by the hash function" do
    for return_type <- [:unsupported, nil, false] do
      assert_raise ArgumentError, ~r/return_type must be one of/, fn ->
        Simhash.hash("abc", return_type: return_type)
      end
    end

    assert_raise ArgumentError, ":int64_signed return type is only available with :siphash", fn ->
      Simhash.hash("abc", hash_function: :md5, return_type: :int64_signed)
    end
  end

  test "similarity rejects return_type" do
    for return_type <- [:binary, nil, false] do
      assert_raise ArgumentError, ":return_type is not supported by similarity/3", fn ->
        Simhash.similarity("abc", "def", return_type: return_type)
      end
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

  test "hash similarity uses the length of the hashes" do
    assert Simhash.hash_similarity([1, 0, 1, 0], [1, 1, 0, 0]) == 0.5
  end

  test "Hamming distance requires equal-length hashes" do
    for {left, right} <- [{[1], [1, 0]}, {[1, 0], [1]}] do
      assert_raise ArgumentError, "hashes must have the same length", fn ->
        Simhash.hamming_distance(left, right)
      end
    end

    assert_raise ArgumentError, "hashes must have the same length", fn ->
      Simhash.hamming_distance([1], [1, 0], 10)
    end
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

  test "binary hashes contain the same bits as list hashes" do
    for hash_function <- [:siphash, :md5, :sha256] do
      options = [ngram_size: 3, hash_function: hash_function]
      bits = Simhash.hash("the quick brown fox", options)
      binary = Simhash.hash("the quick brown fox", [{:return_type, :binary} | options])

      assert for(<<bit::1 <- binary>>, do: bit) == bits
    end
  end
end
