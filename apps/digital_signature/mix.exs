defmodule DigitalSignature.Mixfile do
  use Mix.Project

  def project do
    [
      app: :digital_signature,
      description: "NIF validatatin pkcs7 data and get unpacked data with signer information from it.",
      package: package(),
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:elixir_make] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
      # docs: [
      #   source_ref: "v#\{@version\}",
      #   main: "readme",
      #   extras: ["README.md"]
      # ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {DigitalSignature, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_machina, "~> 2.0", only: [:dev, :test]},
      {:elixir_make, "~> 0.4", runtime: false},
      {:core, in_umbrella: true},
      {:kaffe, "~> 1.11"},
      {:poison, "~> 3.1"}
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
    []
  end
end
