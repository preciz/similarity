# Similarity

[![test](https://github.com/preciz/similarity/actions/workflows/test.yml/badge.svg)](https://github.com/preciz/similarity/actions/workflows/test.yml)

Cosine similarity, Simhash, and Sørensen–Dice implementations.

Full documentation can be found at [https://hexdocs.pm/similarity](https://hexdocs.pm/similarity).

## Installation

Add `similarity` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:similarity, "~> 0.5"}
  ]
end
```

Similarity requires Elixir 1.14 or later.

## Cosine Similarity

Cosine similarity is not sensitive to the scale of the vector:

```elixir
Similarity.cosine([1,2,3], [1,2,3])
1.0
Similarity.cosine([1,2,3], [2,4,6])
1.0
```

Module `Similarity.Cosine` takes care of building a struct and streaming similarities:
(It handles non matching attributes, elements added don't have to have the exact attributes)

```elixir
s = Similarity.Cosine.new()
s = s |> Similarity.Cosine.add("a", [{"bananas", 9}, {"hair_color_r", 124}, {"hair_color_g", 8}, {"hair_color_b", 122}])
s = s |> Similarity.Cosine.add("b", [{"bananas", 19}, {"hair_color_r", 124}, {"hair_color_g", 8}, {"hair_color_b", 122}])
s = s |> Similarity.Cosine.add("c", [{"bananas", 9}, {"hair_color_r", 124}])

s |> Similarity.Cosine.stream |> Enum.to_list
[
  {"a", "b", 1.9967471152702767},
  {"a", "c", 1.4142135623730951},
  {"b", "c", 1.409736747211141}
]

s |> Similarity.Cosine.between("a", "b")
1.9967471152702767
```

`Similarity.cosine_srol/2`
Cosine similarity between two vectors, multiplied by the square root of the length of the vectors.
(In my experience, where the number of common attributes doesn't match between some vectors, this gives a better value.)

```elixir
a = [1,2,3,4]
b = [1,2,3]
c = [1,2,3,4]

Similarity.cosine_srol(a |> Enum.take(3), b)
1.7320508075688772
Similarity.cosine_srol(a, c)
2.0
```

Above even though the first 3 elements of `a` match with `b`, just like `a` with `c`,
the `a` & `c` cosine similarity returns higher value due to more elements matching.
In real world scenario I suggest using this if compared vectors aren't the same length.

## Simhash

```elixir
left = "pork belly jerky brisket tenderloin shank kevin spare ribs"
right = "porchetta pork loin. Leberkas ball tip biltong, beef ribs"

Similarity.simhash(left, right, ngram_size: 3)
0.484375
```

## Sørensen–Dice

```elixir
Similarity.sorensen_dice("this that", "just that")
0.42857142857142855
```

## Performance

The reproducible [Simhash benchmark](bench/simhash.exs) uses `Mix.install/1` to
install pinned versions of Benchee, Similarity, and
[simhash-ex](https://github.com/UniversalAvenue/simhash-ex). It verifies that both
implementations return the same score before benchmarking them:

```console
$ elixir bench/simhash.exs
```

On Linux with an AMD Ryzen 7 8845HS, Elixir 1.20.3, and Erlang/OTP 29.0.5:

| Implementation | Average time | Throughput | Memory |
| --- | ---: | ---: | ---: |
| Similarity 0.5.1 | 55.80 μs | 17.92 K ips | 126.82 KB |
| simhash-ex `e04aa01` | 143.60 μs | 6.96 K ips | 262.54 KB |

For this input, Similarity was 2.57× faster and used 52% less memory. Results vary
by hardware and runtime version.

## License

Similarity is [MIT licensed](LICENSE).
