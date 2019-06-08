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
      elixir: "~> 1.8.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
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
      {:kube_rpc, "~> 0.2.0"},
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
