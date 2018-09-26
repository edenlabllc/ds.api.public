use Mix.Config

config :ocsp_service,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10}
  ]

config :ocsp_service, OCSPService.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "${DB_NAME}",
  username: "${DB_USER}",
  password: "${DB_PASSWORD}",
  hostname: "${DB_HOST}",
  port: "${DB_PORT}",
  pool_size: "${DB_POOL_SIZE}",
  timeout: 15_000,
  pool_timeout: 15_000,
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :kafka_ex,
  brokers: "#{System.get_env("KAFKA_HOST")}:#{System.get_env("KAFKA_PORT")}",
  consumer_group: "${CONSUMER_GROUP}"
