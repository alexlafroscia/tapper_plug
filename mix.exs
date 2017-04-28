defmodule TapperPlug.Mixfile do
  use Mix.Project

  def project do
    [app: :tapper_plug,
     version: "0.1.0",
     elixir: "~> 1.4",
     description: "Plug integration for Tapper",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:tapper, git: "https://github.com/Financial-Times/tapper.git"},
      {:plug, "~> 1.0"}
    ]
  end
end
