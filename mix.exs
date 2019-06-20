defmodule Similarity.MixProject do
  use Mix.Project

  @version "0.1.0"

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

      description: "A library for easy cosine similarity calculation",
      package: package(),
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

  def application do
    [
      extra_application: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end
end
