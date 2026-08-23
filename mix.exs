defmodule Similarity.MixProject do
  use Mix.Project

  @version "0.5.0"

  def project do
    [
      app: :similarity,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [summary: [threshold: 100]],
      source_url: "https://github.com/preciz/similarity",
      name: "Similarity",
      docs: docs(),
      description: "Cosine similarity, Simhash, and Sorensen-Dice implementations",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  defp deps do
    [
      {:fast_ngram, "~> 1.3"},
      {:siphash, "~> 3.0"},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false},
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.4", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Barna Kovacs"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/preciz/similarity"}
    ]
  end

  defp docs do
    [
      main: "Similarity",
      source_ref: "v#{@version}",
      source_url: "https://github.com/preciz/similarity"
    ]
  end
end
