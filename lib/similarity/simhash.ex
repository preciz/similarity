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
    * `:hash_function` - defaults to :siphash, available options are :siphash, :md5, :sha256

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

    hash_similarity(
      hash(left, options),
      hash(right, options),
      @hash_functions_bits[hash_function]
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
    |> Enum.map(&bitstring_to_list/1)
    |> vector_addition()
    |> normalize_bits()
  end

  # implemented as below for performance reasons
  defp do_hash(string, ngram_size, :siphash, :int64_unsigned) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
     n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
     n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
     n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
     n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
     n57, n58, n59, n60, n61, n62, n63, n64] =
      do_hash(string, ngram_size, :siphash, :list)

    <<int64_unsigned :: integer-unsigned-64>> =
      <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
        n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
        n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
        n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
        n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
        n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1>>

    int64_unsigned
  end

  defp do_hash(string, ngram_size, :siphash, :int64_signed) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
     n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
     n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
     n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
     n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
     n57, n58, n59, n60, n61, n62, n63, n64] =
      do_hash(string, ngram_size, :siphash, :list)

    <<int :: integer-signed-64>> =
      <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
        n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
        n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
        n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
        n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
        n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1>>

    int
  end

  defp do_hash(string, ngram_size, :siphash, :binary) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
    n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
    n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
    n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
    n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
    n57, n58, n59, n60, n61, n62, n63, n64] =
      do_hash(string, ngram_size, :siphash, :list)

    <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
      n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
      n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
      n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
      n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
      n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1>>
  end

  defp do_hash(string, ngram_size, :md5, :binary) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
    n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
    n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
    n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
    n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
    n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67,
    n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
    n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
    n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
    n101, n102, n103, n104, n105, n106, n107, n108, n109, n110,
    n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
    n121, n122, n123, n124, n125, n126, n127, n128] =
      do_hash(string, ngram_size, :md5, :list)

    <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
      n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
      n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
      n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
      n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
      n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1, n65::1, n66::1, n67::1,
      n68::1, n69::1, n70::1, n71::1, n72::1, n73::1, n74::1, n75::1, n76::1, n77::1, n78::1,
      n79::1, n80::1, n81::1, n82::1, n83::1, n84::1, n85::1, n86::1, n87::1, n88::1, n89::1,
      n90::1, n91::1, n92::1, n93::1, n94::1, n95::1, n96::1, n97::1, n98::1, n99::1, n100::1,
      n101::1, n102::1, n103::1, n104::1, n105::1, n106::1, n107::1, n108::1, n109::1, n110::1,
      n111::1, n112::1, n113::1, n114::1, n115::1, n116::1, n117::1, n118::1, n119::1, n120::1,
      n121::1, n122::1, n123::1, n124::1, n125::1, n126::1, n127::1, n128::1>>
  end

  defp do_hash(string, ngram_size, :sha256, :binary) do
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
    n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
    n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
    n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
    n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
    n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67,
    n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
    n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
    n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
    n101, n102, n103, n104, n105, n106, n107, n108, n109, n110,
    n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
    n121, n122, n123, n124, n125, n126, n127, n128, n129, n130,
    n131, n132, n133, n134, n135, n136, n137, n138, n139, n140,
    n141, n142, n143, n144, n145, n146, n147, n148, n149, n150,
    n151, n152, n153, n154, n155, n156, n157, n158, n159, n160,
    n161, n162, n163, n164, n165, n166, n167, n168, n169, n170,
    n171, n172, n173, n174, n175, n176, n177, n178, n179, n180,
    n181, n182, n183, n184, n185, n186, n187, n188, n189, n190,
    n191, n192, n193, n194, n195, n196, n197, n198, n199, n200,
    n201, n202, n203, n204, n205, n206, n207, n208, n209, n210,
    n211, n212, n213, n214, n215, n216, n217, n218, n219, n220,
    n221, n222, n223, n224, n225, n226, n227, n228, n229, n230,
    n231, n232, n233, n234, n235, n236, n237, n238, n239, n240,
    n241, n242, n243, n244, n245, n246, n247, n248, n249, n250,
    n251, n252, n253, n254, n255, n256] =
      do_hash(string, ngram_size, :sha256, :list)

    <<n1::1, n2::1, n3::1, n4::1, n5::1, n6::1, n7::1, n8::1, n9::1, n10::1, n11::1, n12::1,
      n13::1, n14::1, n15::1, n16::1, n17::1, n18::1, n19::1, n20::1, n21::1, n22::1, n23::1,
      n24::1, n25::1, n26::1, n27::1, n28::1, n29::1, n30::1, n31::1, n32::1, n33::1, n34::1,
      n35::1, n36::1, n37::1, n38::1, n39::1, n40::1, n41::1, n42::1, n43::1, n44::1, n45::1,
      n46::1, n47::1, n48::1, n49::1, n50::1, n51::1, n52::1, n53::1, n54::1, n55::1, n56::1,
      n57::1, n58::1, n59::1, n60::1, n61::1, n62::1, n63::1, n64::1, n65::1, n66::1, n67::1,
      n68::1, n69::1, n70::1, n71::1, n72::1, n73::1, n74::1, n75::1, n76::1, n77::1, n78::1,
      n79::1, n80::1, n81::1, n82::1, n83::1, n84::1, n85::1, n86::1, n87::1, n88::1, n89::1,
      n90::1, n91::1, n92::1, n93::1, n94::1, n95::1, n96::1, n97::1, n98::1, n99::1, n100::1,
      n101::1, n102::1, n103::1, n104::1, n105::1, n106::1, n107::1, n108::1, n109::1, n110::1,
      n111::1, n112::1, n113::1, n114::1, n115::1, n116::1, n117::1, n118::1, n119::1, n120::1,
      n121::1, n122::1, n123::1, n124::1, n125::1, n126::1, n127::1, n128::1, n129::1, n130::1,
      n131::1, n132::1, n133::1, n134::1, n135::1, n136::1, n137::1, n138::1, n139::1, n140::1,
      n141::1, n142::1, n143::1, n144::1, n145::1, n146::1, n147::1, n148::1, n149::1, n150::1,
      n151::1, n152::1, n153::1, n154::1, n155::1, n156::1, n157::1, n158::1, n159::1, n160::1,
      n161::1, n162::1, n163::1, n164::1, n165::1, n166::1, n167::1, n168::1, n169::1, n170::1,
      n171::1, n172::1, n173::1, n174::1, n175::1, n176::1, n177::1, n178::1, n179::1, n180::1,
      n181::1, n182::1, n183::1, n184::1, n185::1, n186::1, n187::1, n188::1, n189::1, n190::1,
      n191::1, n192::1, n193::1, n194::1, n195::1, n196::1, n197::1, n198::1, n199::1, n200::1,
      n201::1, n202::1, n203::1, n204::1, n205::1, n206::1, n207::1, n208::1, n209::1, n210::1,
      n211::1, n212::1, n213::1, n214::1, n215::1, n216::1, n217::1, n218::1, n219::1, n220::1,
      n221::1, n222::1, n223::1, n224::1, n225::1, n226::1, n227::1, n228::1, n229::1, n230::1,
      n231::1, n232::1, n233::1, n234::1, n235::1, n236::1, n237::1, n238::1, n239::1, n240::1,
      n241::1, n242::1, n243::1, n244::1, n245::1, n246::1, n247::1, n248::1, n249::1, n250::1,
      n251::1, n252::1, n253::1, n254::1, n255::1, n256::1>>
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
