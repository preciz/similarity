defmodule Similarity do
  @moduledoc """
  Contains basic functions for similarity calculation.

  `Similarity.Cosine` - easy cosine similarity calculation

  `Similarity.Simhash` - simhash similarity calculation between two strings

  `Similarity.SorensenDice` - Sorensen-Dice similarity for strings and collections
  """

  @doc """
  For docs see `Similarity.Simhash`
  """
  defdelegate simhash(left, right, options \\ []), to: Similarity.Simhash, as: :similarity

  @doc """
  For docs see `Similarity.SorensenDice`
  """
  defdelegate sorensen_dice(left, right, options \\ []),
    to: Similarity.SorensenDice,
    as: :sorensen_dice

  @doc """
  Calculates Cosine similarity between two vectors.

  [https://en.wikipedia.org/wiki/Cosine_similarity#Definition](https://en.wikipedia.org/wiki/Cosine_similarity#Definition)

  ## Example:
      Similarity.cosine([1, 2, 3], [1, 2, 8])

  Raises `ArgumentError` when the vectors have different lengths or either vector
  has zero magnitude.
  """
  def cosine(list_a, list_b) when is_list(list_a) and is_list(list_b) do
    length_a = length(list_a)
    length_b = length(list_b)

    if length_a != length_b do
      raise ArgumentError,
            "vectors must have the same length, got #{length_a} and #{length_b}"
    end

    {dot_product, squared_magnitude_a, squared_magnitude_b} =
      cosine_components(list_a, list_b, 0, 0, 0)

    magnitude_a = :math.sqrt(squared_magnitude_a)
    magnitude_b = :math.sqrt(squared_magnitude_b)

    if magnitude_a == 0 or magnitude_b == 0 do
      raise ArgumentError, "cosine similarity is undefined for zero-magnitude vectors"
    end

    dot_product / (magnitude_a * magnitude_b)
  end

  @doc """
  Multiplies cosine similarity with the square root of compared vectors length.

  srol here means square root of length

  This gives better comparable numbers where the number of attributes
  compared might differ. You can try to use this instead of `cosine/2`
  if the number of shared attributes differ.

  ## Example:
      Similarity.cosine_srol([1, 2, 3], [1, 2, 8])
  """
  def cosine_srol(list_a, list_b) do
    cosine(list_a, list_b) * :math.sqrt(length(list_a))
  end

  @doc """
  Calculates Euclidean dot product of two vectors.

  [https://en.wikipedia.org/wiki/Euclidean_vector#Dot_product](https://en.wikipedia.org/wiki/Euclidean_vector#Dot_product)

  ## Example:
      iex> Similarity.dot_product([1, 2], [3, 4])
      11

  Raises `ArgumentError` when the vectors have different lengths.
  """
  def dot_product(list_a, list_b, acc \\ 0)

  def dot_product([], [], acc) do
    acc
  end

  def dot_product([h_a | t_a], [h_b | t_b], acc) do
    new_acc = h_a * h_b + acc

    dot_product(t_a, t_b, new_acc)
  end

  def dot_product(list_a, list_b, _acc) when is_list(list_a) and is_list(list_b) do
    raise ArgumentError, "vectors must have the same length"
  end

  @doc """
  Calculates Euclidean magnitude of one vector.

  [https://en.wikipedia.org/wiki/Magnitude_(mathematics)#Euclidean_vector_space](https://en.wikipedia.org/wiki/Magnitude_(mathematics)#Euclidean_vector_space)

  ## Example:
      iex> Similarity.magnitude([2])
      2.0
  """
  def magnitude(list, acc \\ 0)

  def magnitude([], acc) do
    :math.sqrt(acc)
  end

  def magnitude([h | tl], acc) do
    new_acc = acc + h * h

    magnitude(tl, new_acc)
  end

  defp cosine_components([], [], dot_product, squared_magnitude_a, squared_magnitude_b) do
    {dot_product, squared_magnitude_a, squared_magnitude_b}
  end

  defp cosine_components(
         [head_a | tail_a],
         [head_b | tail_b],
         dot_product,
         squared_magnitude_a,
         squared_magnitude_b
       ) do
    cosine_components(
      tail_a,
      tail_b,
      dot_product + head_a * head_b,
      squared_magnitude_a + head_a * head_a,
      squared_magnitude_b + head_b * head_b
    )
  end
end
