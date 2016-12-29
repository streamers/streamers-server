defmodule Streamers.Mixfile do
  use Mix.Project

  def project do
    [app: :streamers,
     version: "0.0.1",
     elixir: "~> 1.4.0-rc.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger]
    ]
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
      {:exredis, github: "oivoodoo/exredis", override: true},
      {:redis_poolex, github: "oivoodoo/redis_poolex"},
      {:poison, "~> 1.5"},
      {:edeliver, ">= 1.2.9"},
      {:exrm, "~> 1.0.6"},
      {:maru, github: "elixir-maru/maru"},
      {:plug_require_header, "~> 0.8"},
      {:uuid, "~> 1.1"},
      {:getopt, "~> 0.8.2"},
      {:erlware_commons, "~> 0.22.0"},
      {:bbmustache, "~> 1.4"},
      {:providers, "~> 1.6"},
    ]
  end
end
