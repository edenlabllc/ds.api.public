use Mix.Config

# General application configuration
config :digital_signature, api_resolvers: [nif_service: DigitalSignatureLibMock]

# Configuration for test environment
config :ex_unit, capture_log: true

# Print only warnings and errors during test
config :logger, level: :warn

# Run acceptance test in concurrent mode
config :digital_signature, sql_sandbox: true

config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 120_000

config :digital_signature,
  kafka: [
    producer: KafkaMock
  ]
