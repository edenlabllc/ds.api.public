defmodule DigitalSignatureUmbrella.MixProject do
  use Mix.Project

  @version "0.1.1"
  def project do
    [
      apps_path: "apps",
      version: @version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [coveralls: :test],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:git_ops, "~> 0.5.0", git: "https://github.com/marinakr/git_ops.git", only: [:dev]},
      {:distillery, "~> 2.0", runtime: false, override: true},
      {:credo, "~> 0.9.3", only: [:dev, :test]},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [test: ["ecto.create", "ecto.migrate", "test"]]
  end
end
