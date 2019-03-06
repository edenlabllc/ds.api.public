use Mix.Config

config :synchronizer_crl, SynchronizerCrl.Web.Endpoint,
  http: [port: 4010],
  server: true,
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Add provider's urls or comment this line to check response
config :synchronizer_crl, SynchronizerCrl.CrlService, preload_crl: ~w()
