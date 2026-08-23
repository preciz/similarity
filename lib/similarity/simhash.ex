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

  @hash_functions [:siphash, :md5, :sha256]
  @hash_function_bits %{siphash: 64, md5: 128, sha256: 256}
  @siphash_key "0123456789ABCDEF"

  @doc """
  Calculates the similarity between the left and right string, using Simhash.
  Returns a float representing similarity between `left` and `right` strings.

  ## Options
    * `:ngram_size` - defaults to 3
    * `:hash_function` - defaults to :siphash, available options are :siphash, :md5, :sha256

  ## Examples

      iex> Similarity.simhash("khan academy", "khan academia")
      0.890625

      iex> Similarity.simhash("khan academy", "academy khan", ngram_size: 1)
      1.0

  """
  @spec similarity(String.t(), String.t(), keyword()) :: float()
  def similarity(left, right, options \\ []) when is_binary(left) and is_binary(right) do
    ngram_size = options[:ngram_size] || 3
    hash_function = options[:hash_function] || :siphash

    if String.length(left) < ngram_size or String.length(right) < ngram_size do
      raise ArgumentError, """
        left and right strings must be at least #{inspect(ngram_size)} characters long.
        when using ngram_size of #{inspect(ngram_size)}
      """
    end

    if hash_function not in @hash_functions do
      raise ArgumentError, """
        hash_function must be one of #{inspect(@hash_functions)}
      """
    end

    hash_similarity(
      hash(left, options),
      hash(right, options),
      @hash_function_bits[hash_function]
    )
  end

  @doc """
  Returns the hash for the given string and `hash_function` in the given `return_type`.

  ## Options

    * `:ngram_size` - defaults to 3
    * `:hash_function` - defaults to :siphash, available options are :siphash, :md5, :sha256
    * `:return_type` - defaults to :list, available options are :list, :int64_unsigned, :int64_signed, :binary

  The return types `:int64_unsigned` and `:int64_signed` are only available for the `:siphash` hash function.

  ## Examples

      Similarity.Simhash.hash("alma korte", [])
      [1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, ...]

      iex> Similarity.Simhash.hash("alma korte", ngram_size: 3, hash_function: :siphash, return_type: :int64_unsigned)
      15012197954348909067

      iex> Similarity.Simhash.hash("alma korte", ngram_size: 3, hash_function: :siphash, return_type: :int64_signed)
      -3434546119360642549

  """
  @spec hash(String.t(), keyword()) :: list(0 | 1) | integer() | binary()
  def hash(string, options) do
    ngram_size = options[:ngram_size] || 3
    hash_function = options[:hash_function] || :siphash
    return_type = options[:return_type] || :list

    do_hash(string, ngram_size, hash_function, return_type)
  end

  defp do_hash(string, ngram_size, hash_function, :list) do
    if String.length(string) < ngram_size do
      raise ArgumentError,
            "string must be at least #{ngram_size} characters long when using ngram_size #{ngram_size}"
    end

    string
    |> FastNgram.letter_ngrams(ngram_size)
    |> hash_ngrams(hash_function)
    |> normalize_bits()
  end

  defp do_hash(string, ngram_size, :siphash, :int64_unsigned) do
    <<integer::unsigned-64>> = do_hash(string, ngram_size, :siphash, :binary)
    integer
  end

  defp do_hash(string, ngram_size, :siphash, :int64_signed) do
    <<integer::signed-64>> = do_hash(string, ngram_size, :siphash, :binary)
    integer
  end

  defp do_hash(string, ngram_size, hash_function, :binary)
       when hash_function in @hash_functions do
    string
    |> do_hash(ngram_size, hash_function, :list)
    |> bits_to_bitstring()
  end

  defp hash_ngrams([ngram | ngrams], hash_function) do
    initial_votes =
      hash_function
      |> hash_ngram(ngram)
      |> bitstring_to_list()

    Enum.reduce(ngrams, initial_votes, fn next_ngram, votes ->
      hash_function
      |> hash_ngram(next_ngram)
      |> add_hash(votes)
    end)
  end

  defp hash_ngram(:siphash, ngram), do: <<SipHash.hash!(@siphash_key, ngram)::64>>
  defp hash_ngram(:md5, ngram), do: :crypto.hash(:md5, ngram)
  defp hash_ngram(:sha256, ngram), do: :crypto.hash(:sha256, ngram)

  defp add_hash(<<1::1, hash::bitstring>>, [vote | votes]),
    do: [vote + 1 | add_hash(hash, votes)]

  defp add_hash(<<0::1, hash::bitstring>>, [vote | votes]),
    do: [vote - 1 | add_hash(hash, votes)]

  defp add_hash(<<>>, []), do: []

  defp bits_to_bitstring(bits) do
    bits
    |> Enum.map(&<<&1::1>>)
    |> :erlang.list_to_bitstring()
  end

  @doc false
  def hash_similarity(left, right) do
    hash_similarity(left, right, length(left))
  end

  def hash_similarity(left, right, hash_length) do
    1 - hamming_distance(left, right) / hash_length
  end

  @doc """
  Returns the Hamming distance between the `left` and `right` hash,
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

  defp bitstring_to_list(<<1::1, data::bitstring>>), do: [1 | bitstring_to_list(data)]
  defp bitstring_to_list(<<0::1, data::bitstring>>), do: [-1 | bitstring_to_list(data)]
  defp bitstring_to_list(<<>>), do: []

  defp normalize_bits([head | tail]) when head > 0, do: [1 | normalize_bits(tail)]
  defp normalize_bits([_head | tail]), do: [0 | normalize_bits(tail)]
  defp normalize_bits([]), do: []
end
