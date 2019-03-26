use Mix.Config

config :synchronizer_crl, sql_sandbox: true

config :synchronizer_crl, SynchronizerCrl.Web.Endpoint,
  http: [port: 4011],
  server: true
