defmodule Api.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :api,
      description: "This api allows to validate pkcs7 data and get unpacked data with signer information from it.",
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      "ecto.setup": &umbrella_ecto_setup/1,
      test: ["ecto.setup", "test"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {API, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kafka_ex, "~> 0.8.3"},
      {:eview, "~> 0.12.0"},
      {:cowboy, "~> 1.1"},
      {:plug_cowboy, "~> 1.0"},
      {:phoenix, "~> 1.3"},
      {:plug_logger_json, "~> 0.5"},
      {:confex, "~> 3.3"},
      {:mox, "~> 0.3", only: :test},
      {:digital_signature, in_umbrella: true}
    ]
  end

  defp umbrella_ecto_setup(_) do
    Mix.shell().cmd("cd ../core && mix ecto.setup")
  end
end
