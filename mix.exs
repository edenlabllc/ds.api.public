defmodule DigitalSignatureUmbrella.MixProject do
  use Mix.Project

  @version "0.3.0"
  def project do
    [
      apps_path: "apps",
      version: @version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [coveralls: :test],
      test_coverage: [tool: ExCoveralls],
      docs: [
        filter_prefix: "*.Rpc"
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:git_ops, "~> 0.6.0", only: [:dev]},
      {:distillery, "~> 2.0", runtime: false, override: true},
      {:credo, "~> 0.9.3", only: [:dev, :test]},
      {:excoveralls, "~> 0.10.6", only: [:dev, :test]},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [test: ["ecto.create", "ecto.migrate", "test"]]
  end
end
