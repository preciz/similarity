defmodule Similarity.SorensenDice do
  @moduledoc """
  String similarity comparison with the Sorensen-Dice algorithm.

  [Wikipedia](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient)
  """

  @doc """
  Calculates the similarity between the left and right attributes,
  using Sorensen-Dice coefficient.

  Attribute can be a string, list or a MapSet.

  ## Examples

      iex> Similarity.SorensenDice.sorensen_dice("alma", "korte")
      0.0

      iex> Similarity.SorensenDice.sorensen_dice("alma", "alma")
      1.0

      iex> Similarity.SorensenDice.sorensen_dice("just letters", "letters just", ngram_size: 1)
      1.0

      iex> Similarity.SorensenDice.sorensen_dice("this that", "just that")
      0.42857142857142855

      iex> Similarity.SorensenDice.sorensen_dice([1, 2, 3], [1, 2, 3])
      1.0

      iex> Similarity.SorensenDice.sorensen_dice([1, 2, 3], [1, 2, 3, 4])
      0.8571428571428571

  """
  def sorensen_dice(string1, string2, options \\ [])

  def sorensen_dice(same, same, _opts) when is_binary(same), do: 1.0

  def sorensen_dice(string1, string2, options) when is_binary(string1) and is_binary(string2) do
    ngram_size = Keyword.get(options, :ngram_size, 3)

    if String.length(string1) < ngram_size or String.length(string2) < ngram_size do
      raise ArgumentError, """
        left and right strings must be at least #{ngram_size} characters long.
        when using ngram_size of #{ngram_size}
      """
    end

    ngrams1 = FastNgram.letter_ngrams(string1, ngram_size)
    ngrams2 = FastNgram.letter_ngrams(string2, ngram_size)

    sorensen_dice(ngrams1, ngrams2, options)
  end

  def sorensen_dice(list1, list2, options) when is_list(list1) and is_list(list2) do
    sorensen_dice(MapSet.new(list1), MapSet.new(list2), options)
  end

  def sorensen_dice(mapset1, mapset2, _options)
      when is_struct(mapset1, MapSet) and is_struct(mapset2, MapSet) do
    intersect = MapSet.intersection(mapset1, mapset2)
    intersect_length = Enum.count(intersect)

    case intersect_length do
      0 -> 0.0
      _ -> 2 * intersect_length / (Enum.count(mapset1) + Enum.count(mapset2))
    end
  end
end
