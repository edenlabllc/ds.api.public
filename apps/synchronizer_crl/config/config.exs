use Mix.Config

# Configure crl scheduler
config :synchronizer_crl, SynchronizerCrl.Worker,
  resync_timeout: {:system, :integer, "RESYNC_TIMEOUT", 60_000},
  sync: true

import_config "#{Mix.env()}.exs"
