defmodule Similarity.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :similarity,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/preciz/similarity",

      name: "Similarity",
      docs: docs(),

      description: "A library for cosine similarity & simhash calculation",
      package: package(),
    ]
  end

  def application do
    [
      extra_application: []
    ]
  end

  defp deps do
    [
      {:fast_ngram, "~> 1.0"},
      {:siphash, "~> 3.0"},
      {:ex_doc, "~> 0.22.6", only: :dev, runtime: false}
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
      source_url: "https://github.com/preciz/similarity",
    ]
  end
end
