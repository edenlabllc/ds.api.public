defmodule OCSPService.MixProject do
  use Mix.Project

  def project do
    [
      app: :ocsp_service,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {OCSPService.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.1.0"},
      {:digital_signature, in_umbrella: true},
      {:mox, "~> 0.3", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.setup": &umbrella_ecto_setup/1,
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp umbrella_ecto_setup(_) do
    Mix.shell().cmd("cd ../core && mix ecto.setup")
  end
end
