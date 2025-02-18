use Mix.Config

config :core, Core.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :ex_unit, capture_log: true
config :logger, level: :error
