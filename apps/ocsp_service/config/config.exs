use Mix.Config

config :ocsp_service,
  namespace: OCSPService,
  kafka: [
    consumer: OCSPService.Kafka.Consumer,
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10},
    topic: {:system, "DS_KAFKA_TOPIC", "digital_signature"}
  ]

config :ocsp_service, ecto_repos: [OCSPService.Repo]

config :ocsp_service, OCSPService.Repo,
  database: "ocsp_service",
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST"),
  port: "5432"

config :ocsp_service, OCSPService.EmailSender,
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  warning_receiver: System.get_env("SMTP_WARNING_RECEIVER")

config :ocsp_service, :api_resolvers, email_sender: OCSPService.EmailSender

config :kafka_ex,
  brokers: "#{System.get_env("KAFKA_HOST")}:#{System.get_env("KAFKA_PORT")}",
  consumer_group: "digital_signature",
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  commit_interval: 5_000,
  auto_offset_reset: :earliest,
  commit_threshold: 100,
  kafka_version: "1.1.0"

import_config "#{Mix.env()}.exs"
