defmodule Similarity do
  @doc """
  Calculates Cosine similarity between two vectors

  https://en.wikipedia.org/wiki/Cosine_similarity#Definition
  """
  def cosine(list_a, list_b) when length(list_a) == length(list_b) do
    dot_product(list_a, list_b) / (magnitude(list_a) * magnitude(list_b))
  end

  @doc """
  Calculates Euclidean dot product of two vectors

  https://en.wikipedia.org/wiki/Euclidean_vector#Dot_product
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
  Calculates Euclidean magnitude of one vector

  https://en.wikipedia.org/wiki/Magnitude_(mathematics)#Euclidean_vector_space
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
