defmodule Streamers.Mixfile do
  use Mix.Project

  def project do
    [app: :streamers,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
        :redis_poolex,
        :exredis,
        :xmerl,
        :edeliver,
        :exrm,
        :runtime_tools,
      ],
      mod: {Streamers, []},
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
      {:redis_poolex, github: "oivoodoo/redis_poolex"},
      {:poison, "~> 1.5"},
      {:edeliver, ">= 1.2.9"},
      {:exrm, "~> 1.0.6"},
      {:maru, github: "elixir-maru/maru"},
    ]
  end
end
