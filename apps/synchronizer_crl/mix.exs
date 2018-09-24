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
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ex_machina, :core],
      mod: {SynchronizerCrl.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:confex, "~> 3.2"},
      {:httpoison, "~> 1.1.0"},
      {:core, in_umbrella: true}
    ]
  end

  defp aliases do
    [test: ["ecto.create", "ecto.migrate", "test"]]
  end
end
