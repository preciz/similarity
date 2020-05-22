defmodule Similarity.Simhash do
  @moduledoc """
  Simhash string similarity algorithm.
  [Description of Simhash](https://matpalm.com/resemblance/simhash/)

      iex> Similarity.simhash("Barna", "Kovacs")
      0.59375

      iex> Similarity.simhash("Austria", "Australia")
      0.65625

  """
  @moduledoc since: "0.1.1"

  @doc """
  Calculates the similarity between the left and right string, using Simhash.
  Returns a float representing similarity between `left` and `right` strings.

  ## Options
    * `:ngram_size` - defaults to 3

  ## Examples

      iex> Similarity.simhash("khan academy", "khan academia")
      0.890625

      iex> Similarity.simhash("khan academy", "academy khan", ngram_size: 1)
      1.0

  """
  @spec similarity(String.t(), String.t(), pos_integer) :: float
  def similarity(left, right, options \\ []) when is_binary(left) and is_binary(right) do
    n = options[:ngram_size] || 3

    hash_similarity(hash(left, n), hash(right, n))
  end

  @doc """
  Returns the hash for the given string.

  ## Examples

      Similarity.Simhash.hash("alma korte", 3)
      [1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, ...]

  """
  @spec hash(String.t(), pos_integer) :: list(0 | 1)
  def hash(string, n) do
    string
    |> ngram_hashes(n)
    |> vector_addition
    |> normalize_bits
  end

  @doc false
  def ngram_hashes(string, n) do
    string
    |> FastNgram.letter_ngrams(n)
    |> Enum.map(&(&1 |> siphash |> to_list))
  end

  @doc false
  def hash_similarity(left, right) do
    1 - hamming_distance(left, right) / 64
  end

  @doc """
  Returns Hamming distance between the `left` and `right` hash,
  given as lists of bits.

  ## Examples

      iex> Similarity.Simhash.hamming_distance([1, 1, 0, 1, 0], [0, 1, 1, 1, 0])
      2

  """
  def hamming_distance(left, right, acc \\ 0)

  def hamming_distance([same | tl_left], [same | tl_right], acc) do
    hamming_distance(tl_left, tl_right, acc)
  end

  def hamming_distance([_ | tl_left], [_ | tl_right], acc) do
    hamming_distance(tl_left, tl_right, acc + 1)
  end

  def hamming_distance([], [], acc), do: acc

  defp vector_addition([hd_list | tl_lists]) do
    vector_addition(tl_lists, hd_list)
  end

  defp vector_addition([hd_list | tl_lists], acc_list) do
    new_acc_list = :lists.zipwith(fn x, y -> x + y end, hd_list, acc_list)

    vector_addition(tl_lists, new_acc_list)
  end

  defp vector_addition([], acc_list), do: acc_list

  defp to_list(<<1::size(1), data::bitstring>>), do: [1 | to_list(data)]
  defp to_list(<<0::size(1), data::bitstring>>), do: [-1 | to_list(data)]
  defp to_list(<<>>), do: []

  defp normalize_bits([head | tail]) when head > 0, do: [1 | normalize_bits(tail)]
  defp normalize_bits([_head | tail]), do: [0 | normalize_bits(tail)]
  defp normalize_bits([]), do: []

  defp siphash(str) do
    int = SipHash.hash!("0123456789ABCDEF", str)

    <<int::64>>
  end
end
