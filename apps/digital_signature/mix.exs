defmodule DigitalSignature.Mixfile do
  use Mix.Project

  def project do
    [
      app: :digital_signature,
      description: "NIF validatatin pkcs7 data and get unpacked data with signer information from it.",
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:elixir_make, :phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      docs: [
        source_ref: "v#\{@version\}",
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [
        :logger,
        :confex,
        :runtime_tools,
        :jason,
        :cowboy,
        :httpoison,
        :ecto,
        :postgrex,
        :phoenix,
        :phoenix_pubsub,
        :eview,
        :runtime_tools
      ],
      mod: {DigitalSignature, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:distillery, "~> 2.0", runtime: false},
      {:confex, "~> 3.3"},
      {:ecto, "~> 2.2"},
      {:cowboy, "~> 1.1"},
      {:httpoison, "~> 1.1.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix, "~> 1.3"},
      {:eview, "~> 0.12.0"},
      {:plug_logger_json, "~> 0.5"},
      {:ecto_logger_json, "~> 0.1"},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:jvalid, "~> 0.6.0"},
      {:credo, "~> 0.9.3", only: [:dev, :test]},
      {:jason, "~> 1.0"},
      {:ex_machina, "~> 2.0", only: [:dev, :test]},
      {:mox, "~> 0.3", only: :test},
      {:nex_json_schema, ">= 0.7.2"},
      {:elixir_make, "~> 0.4", runtime: false},
      {:kafka_ex, "~> 0.8.3"},
      {:core, in_umbrella: true}
    ]
  end

  defp package do
    [
      contributors: ["edenlab"],
      maintainers: ["edenlab"],
      licenses: ["LISENSE.md"],
      links: %{github: "https://github.com/edenlabllc/ds.api"},
      files: ~w(lib LICENSE.md mix.exs README.md)
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
