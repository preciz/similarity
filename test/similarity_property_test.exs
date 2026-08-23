defmodule SimilarityPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Similarity.Cosine

  @unicode_graphemes ["á", "ß", "€", "界", "🙂", "é"]

  property "cosine similarity is symmetric, bounded, and identical vectors score one" do
    check all(
            length <- integer(1..20),
            left <- nonzero_vector(length),
            right <- nonzero_vector(length)
          ) do
      left_to_right = Similarity.cosine(left, right)
      right_to_left = Similarity.cosine(right, left)

      assert_in_delta left_to_right, right_to_left, 1.0e-12
      assert left_to_right >= -1.0 - 1.0e-12
      assert left_to_right <= 1.0 + 1.0e-12
      assert_in_delta Similarity.cosine(left, left), 1.0, 1.0e-12
    end
  end

  property "cosine similarity rejects randomized unequal vector lengths" do
    check all(
            shorter_length <- integer(0..20),
            difference <- integer(1..20),
            shorter <- vector(shorter_length),
            longer <- vector(shorter_length + difference)
          ) do
      assert_raise ArgumentError, ~r/vectors must have the same length/, fn ->
        Similarity.cosine(shorter, longer)
      end

      assert_raise ArgumentError, ~r/vectors must have the same length/, fn ->
        Similarity.cosine(longer, shorter)
      end
    end
  end

  property "Simhash is symmetric and bounded for Unicode n-grams" do
    check all(
            ngram_size <- integer(1..4),
            left <- unicode_string(ngram_size),
            right <- unicode_string(ngram_size),
            hash_function <- member_of([:siphash, :md5, :sha256])
          ) do
      options = [ngram_size: ngram_size, hash_function: hash_function]
      left_to_right = Similarity.simhash(left, right, options)
      right_to_left = Similarity.simhash(right, left, options)

      assert left_to_right == right_to_left
      assert left_to_right >= 0.0
      assert left_to_right <= 1.0
      assert Similarity.simhash(left, left, options) == 1.0
    end
  end

  property "a full-length Unicode n-gram hashes like the underlying hash function" do
    check all(
            string <- unicode_string(1),
            hash_function <- member_of([:siphash, :md5, :sha256])
          ) do
      actual =
        Similarity.Simhash.hash(string,
          ngram_size: String.length(string),
          hash_function: hash_function,
          return_type: :binary
        )

      expected =
        case hash_function do
          :siphash -> <<SipHash.hash!("0123456789ABCDEF", string)::64>>
          hash_function -> :crypto.hash(hash_function, string)
        end

      assert actual == expected
    end
  end

  property "Sørensen-Dice is symmetric and bounded for Unicode n-grams" do
    check all(
            ngram_size <- integer(1..4),
            left <- unicode_string(ngram_size),
            right <- unicode_string(ngram_size)
          ) do
      options = [ngram_size: ngram_size]
      left_to_right = Similarity.sorensen_dice(left, right, options)
      right_to_left = Similarity.sorensen_dice(right, left, options)

      assert left_to_right == right_to_left
      assert left_to_right >= 0.0
      assert left_to_right <= 1.0
      assert Similarity.sorensen_dice(left, left, options) == 1.0
    end
  end

  property "Sørensen-Dice is symmetric and bounded for non-empty lists" do
    check all(
            left <- list_of(integer(-20..20), min_length: 1, max_length: 30),
            right <- list_of(integer(-20..20), min_length: 1, max_length: 30)
          ) do
      left_to_right = Similarity.sorensen_dice(left, right)
      right_to_left = Similarity.sorensen_dice(right, left)

      assert left_to_right == right_to_left
      assert left_to_right >= 0.0
      assert left_to_right <= 1.0
      assert Similarity.sorensen_dice(left, left) == 1.0
    end
  end

  property "cosine stream emits every unique pair exactly once" do
    check all(entry_count <- integer(0..25)) do
      ids = if entry_count == 0, do: [], else: Enum.to_list(1..entry_count)

      cosine =
        Enum.reduce(ids, Cosine.new(), fn id, acc ->
          Cosine.add(acc, id, [{:value, id}])
        end)

      pairs = cosine |> Cosine.stream() |> Enum.to_list()
      actual_pairs = MapSet.new(pairs, fn {left, right, _score} -> MapSet.new([left, right]) end)

      expected_pairs =
        for {left, index} <- Enum.with_index(ids),
            right <- Enum.drop(ids, index + 1),
            into: MapSet.new(),
            do: MapSet.new([left, right])

      expected_count = div(entry_count * (entry_count - 1), 2)

      assert length(pairs) == expected_count
      assert MapSet.size(actual_pairs) == expected_count
      assert actual_pairs == expected_pairs
    end
  end

  defp vector(length) do
    fixed_list(List.duplicate(integer(-100..100), length))
  end

  defp nonzero_vector(length) do
    fixed_list([
      one_of([integer(-100..-1), integer(1..100)])
      | List.duplicate(integer(-100..100), length - 1)
    ])
  end

  defp unicode_string(min_length) do
    @unicode_graphemes
    |> member_of()
    |> list_of(min_length: min_length, max_length: 20)
    |> map(&Enum.join/1)
  end
end
