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
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OCSPService.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.0", runtime: false},
      {:kafka_ex, "~> 0.8.3"},
      {:mox, "~> 0.4.0", only: :test},
      {:confex, "~> 3.2"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:httpoison, "~> 1.1.0"},
      {:digital_signature, in_umbrella: true},
      {:ex_machina, "~> 2.0", only: [:dev, :test]},
      {:gen_smtp, git: "https://github.com/Vagabond/gen_smtp.git"}
    ]
  end
end
