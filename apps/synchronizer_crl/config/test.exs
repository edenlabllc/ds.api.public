use Mix.Config

# Add provider's urls or comment this line to check response
config :synchronizer_crl, SynchronizerCrl.CrlService, preload_crl: ~w()

config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 120_000,
  database: "ds_test"
