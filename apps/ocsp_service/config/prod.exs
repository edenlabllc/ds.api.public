use Mix.Config

config :ocsp_service,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10},
    topic: {:system, "DS_KAFKA_TOPIC", "digital_signature"}
  ]

config :kafka_ex,
  brokers: "#{System.get_env("KAFKA_HOST")}:#{System.get_env("KAFKA_PORT")}",
  consumer_group: {:system, "CONSUMER_GROUP"}

# Configures Database
config :ocsp_service, OCSPService.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME"},
  username: {:system, "DB_USER"},
  password: {:system, "DB_PASSWORD"},
  hostname: {:system, "DB_HOST"},
  port: {:system, :integer, "DB_PORT"},
  pool_size: {:system, :integer, "DB_POOL_SIZE"},
  timeout: 15_000,
  pool_timeout: 15_000

# Email
config :ocsp_service, OCSPService.EmailSender,
  relay: {:system, "SMTP_RELAY"},
  username: {:system, "SMTP_USERNAME"},
  password: {:system, "$SMTP_PASSWORD"},
  warning_receiver: {:system, "SMTP_WARNING_RECEIVER"}
