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
  @hash_functions_bits %{siphash: 64, md5: 128, sha256: 256}

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

    hash_similarity(hash(left, options), hash(right, options), @hash_functions_bits[hash_function])
  end

  @doc """
  Returns the hash for the given string and `hash_function` in the given `return_type`.

  ## Examples

      Similarity.Simhash.hash("alma korte")
      [1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, ...]

      iex> Similarity.Simhash.hash("alma korte", ngram_size: 3, hash_function: :siphash, return_type: :int64_unsigned)
      15012197954348909067

      iex> Similarity.Simhash.hash("alma korte", ngram_size: 3, hash_function: :siphash, return_type: :int64_signed)
      -3434546119360642549

  """
  @spec hash(String.t(), keyword) :: list(0 | 1) | integer
  def hash(string, options) do
    ngram_size = options[:ngram_size] || 3
    hash_function = options[:hash_function] || :siphash
    return_type = options[:return_type] || :list

    hash(string, ngram_size, hash_function, return_type)
  end

  def hash(string, ngram_size, hash_function, :list) do
    if String.length(string) < ngram_size do
      raise ArgumentError,
            "string must be at least #{ngram_size} characters long when using ngram_size #{ngram_size}"
    end

    string
    |> FastNgram.letter_ngrams(ngram_size)
    |> hash_ngrams(hash_function)
    |> Enum.map(&bitstring_to_list/1)
    |> vector_addition()
    |> normalize_bits()
  end

  # implemented as below for performance reasons
  def hash(string, ngram_size, :siphash, :int64_unsigned) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
     n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
     n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
     n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
     n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
     n57, n58, n59, n60, n61, n62, n63, n64] =
      hash(string, ngram_size, :siphash, :list)

    <<int64_unsigned :: integer-unsigned-64>> =
      <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
        n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
        n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
        n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
        n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
        n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1>>

    int64_unsigned
  end

  def hash(string, ngram_size, :siphash, :int64_signed) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
     n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
     n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
     n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
     n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
     n57, n58, n59, n60, n61, n62, n63, n64] =
      hash(string, ngram_size, :siphash, :list)

    <<int :: integer-signed-64>> =
      <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
        n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
        n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
        n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
        n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
        n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1>>

    int
  end

  defp hash_ngrams(ngrams, hash_function, acc \\ [])
  defp hash_ngrams([], _hash_function, acc), do: acc

  defp hash_ngrams([ngram | tl], hash_function, acc) do
    hash_ngrams(tl, hash_function, [hash_ngram(hash_function, ngram) | acc])
  end

  defp hash_ngram(:siphash, ngram), do: siphash(ngram)
  defp hash_ngram(:md5, ngram), do: :crypto.hash(:md5, ngram)
  defp hash_ngram(:sha256, ngram), do: :crypto.hash(:sha256, ngram)

  @doc false
  def hash_similarity(left, right) do
    hash_similarity(left, right, length(left))
  end

  def hash_similarity(left, right, length) do
    1 - hamming_distance(left, right) / length
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

  defp bitstring_to_list(<<1::size(1), data::bitstring>>), do: [1 | bitstring_to_list(data)]
  defp bitstring_to_list(<<0::size(1), data::bitstring>>), do: [-1 | bitstring_to_list(data)]
  defp bitstring_to_list(<<>>), do: []

  defp normalize_bits([head | tail]) when head > 0, do: [1 | normalize_bits(tail)]
  defp normalize_bits([_head | tail]), do: [0 | normalize_bits(tail)]
  defp normalize_bits([]), do: []

  defp siphash(str) do
    int = SipHash.hash!("0123456789ABCDEF", str)

    <<int::64>>
  end
end
