use Mix.Config

config :synchronizer_crl, sql_sandbox: true

config :synchronizer_crl, SynchronizerCrl.Web.Endpoint,
  http: [port: 4011],
  server: true

# Add provider's urls or comment this line to check response
config :synchronizer_crl, SynchronizerCrl.CrlService, preload_crl: ~w()
