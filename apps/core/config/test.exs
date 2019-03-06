use Mix.Config

config :kaffe,
  producer: [
    endpoints: System.get_env("KAFKA_BROKERS")
  ]

config :core, Core.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :ex_unit, capture_log: true
config :logger, level: :warn
