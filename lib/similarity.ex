defmodule Similarity do
  @moduledoc """
  Contains basic functions for similarity calculation.

  `Similarity.Cosine` - easy cosine similarity calculation

  `Similarity.Simhash` - simhash similarity calculation between two strings
  """

  defdelegate simhash(left, right, options \\ []), to: Similarity.Simhash, as: :similarity

  @doc """
  Calculates Cosine similarity between two vectors.

  [https://en.wikipedia.org/wiki/Cosine_similarity#Definition](https://en.wikipedia.org/wiki/Cosine_similarity#Definition)

  ## Example:
      Similarity.cosine([1, 2, 3], [1, 2, 8])
  """
  def cosine(list_a, list_b) when length(list_a) == length(list_b) do
    dot_product(list_a, list_b) / (magnitude(list_a) * magnitude(list_b))
  end

  @doc """
  Multiplies cosine similarity with the square root of compared vectors length.

  srol here means square root of length

  This gives better comparable numbers in real life where the number of attributes compared might differ.
  Use this if the number of shared attributes between real world objects differ.

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
  """
  def dot_product(list_a, list_b, acc \\ 0)

  def dot_product([], [], acc) do
    acc
  end

  def dot_product([h_a | t_a], [h_b | t_b], acc) do
    new_acc = h_a * h_b + acc

    dot_product(t_a, t_b, new_acc)
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
    square = :math.pow(h, 2)
    new_acc = acc + square

    magnitude(tl, new_acc)
  end
end
