use Mix.Config

# Add provider's urls or comment this line to check response
config :synchronizer_crl, SynchronizerCrl.CrlService, preload_crl: ~w()

config :core, Core.Repo, database: "ocsp_service_dev"
