Mix.install([
  {:benchee, "== 1.5.1"},
  {:similarity, "== 0.5.1"},
  # simhash-ex is published as :simhash; this revision supports current Elixir.
  {:simhash,
   git: "https://github.com/UniversalAvenue/simhash-ex.git",
   ref: "e04aa014e39ea2a7f53baf30f9d23c1e7cf6cd21"}
])

left = "pork belly jerky brisket tenderloin shank kevin spare ribs"
right = "porchetta pork loin. Leberkas ball tip biltong, beef ribs"

Benchee.run(
  %{
    "similarity 0.5.1" => fn -> Similarity.simhash(left, right) end,
    "simhash-ex e04aa01" => fn -> Simhash.similarity(left, right) end
  },
  pre_check: :all_same,
  warmup: 2,
  time: 5,
  memory_time: 2
)
