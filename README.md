# Similarity

A library for easy cosine similarity calculation

Cosine similarity is not sensitive to the scale of the vector!

```elixir
iex(1)> Similarity.cosine([1,2,3], [1,2,3])
1.0
iex(2)> Similarity.cosine([1,2,3], [2,4,6])
1.0
```

## Installation

The package can be installed
by adding `similarity` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:similarity, "~> 0.1.0"}
  ]
end
```

## Usage

### Easy usage
Module `Similarity.Cosine` takes care of building a struct and streaming similarities:
(It handles non matching attributes, elements added don't have to have the exact attributes)

```elixir
iex(1)> s = Similarity.Cosine.new()
iex(2)> s = s |> Similarity.Cosine.add("a", [{"bananas", 9}, {"hair_color_r", 124}, {"hair_color_g", 8}, {"hair_color_b", 122}])
iex(3]> s = s |> Similarity.Cosine.add("b", [{"bananas", 19}, {"hair_color_r", 124}, {"hair_color_g", 8}, {"hair_color_b", 122}])
iex(4)> s = s |> Similarity.Cosine.add("c", [{"bananas", 9}, {"hair_color_r", 124}])

iex(5)> s |> Similarity.Cosine.stream |> Enum.to_list
[
  {"a", "b", 1.9967471152702767},
  {"a", "c", 1.4142135623730951},
  {"b", "c", 1.409736747211141}
]
```

Or use with `Similarity.Cosine.between/3`:

```elixir
iex(6)> s |> Similarity.Cosine.between("a", "b")
1.9967471152702767
```

### Basic usage

Cosine similarity between two vectors
```elixir
iex(1)> Similarity.cosine([1,2,3], [3,2,0])
0.5188745216627709
```

Cosine similarity between two vectors, multiplied by the square root of the length of the vectors.
(In my experience where number of attributes don't match this works beautifully).
```elixir
iex(1)> a = [1,2,3,4]
iex(2)> b = [1,2,3]
iex(3)> c = [1,2,3,4]

iex(4)> Similarity.cosine_srol(a |> Enum.take(3), b)
1.7320508075688772
iex(5)> Similarity.cosine_srol(a, c)
2.0
```

Above even though the first 3 elements of `a` match with `b`, just like `a` with `c`,
the `a` & `c` cosine similarity returns higher value due to more elements matching.
In real world scenario I suggest using this if compared vectors aren't the same length.

## Docs

Docs can be found at [https://hexdocs.pm/similarity](https://hexdocs.pm/similarity).

