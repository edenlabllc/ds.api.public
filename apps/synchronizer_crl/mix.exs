defmodule SynchronizerCrl.MixProject do
  use Mix.Project

  def project do
    [
      app: :synchronizer_crl,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {SynchronizerCrl.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4.0-rc.3", override: true},
      {:cowboy, "~> 1.1"},
      {:plug_cowboy, "~> 1.0"},
      {:plug_logger_json, "~> 0.5"},
      {:confex, "~> 3.3"},
      {:httpoison, "~> 1.1.0"},
      {:floki, "~> 0.20.4"},
      {:core, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      "ecto.setup": &umbrella_ecto_setup/1,
      test: ["ecto.setup", "test"]
    ]
  end

  defp umbrella_ecto_setup(_) do
    Mix.shell().cmd("cd ../core && mix ecto.setup")
  end
end
