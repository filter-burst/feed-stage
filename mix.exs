defmodule FeedStage.Mixfile do
  use Mix.Project

  def project do
    [app: :feed_stage,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :scrape, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:scrape, "~> 1.2", git: "git://github.com/craigambrose/elixir-scrape.git"},
      {:gen_stage, "~> 0.11"},
      {:stubr, "~> 1.5.0"}
    ]
  end
end
