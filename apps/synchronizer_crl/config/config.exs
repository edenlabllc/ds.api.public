use Mix.Config

config :synchronizer_crl, SynchronizerCrl.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kM4g3grYc77xl0Zglf381h8g6EgOBSH18TbWwMB1UCdWHxFFkIZcF8Ci3w9ZtLCF",
  instrumenters: [LoggerJSON.Phoenix.Instruments]

config :phoenix, :json_library, Jason

# Configure crl scheduler
config :synchronizer_crl, SynchronizerCrl.CrlService,
  retry_crl_timeout: {:system, :integer, "PROVIDER_SYNC_RETRY_TIMEOUT", 3_600_000},
  preload_crl: ~w()

import_config "#{Mix.env()}.exs"
