use Mix.Config

config :certificate_check, CertificateCheck.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "certificate_check_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :certificate_check,
  namespace: CertificateCheck,
  kafka: [
    consumer: CertificateCheck.Kafka.Consumer
  ]

config :certificate_check, ecto_repos: [CertificateCheck.Repo]

config :certificate_check, CertificateCheck.Repo,
  database: "certificate_check",
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST"),
  port: "5432"

config :certificate_check, CertificateCheck.EmailSender,
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  warning_receiver: System.get_env("SMTP_WARNING_RECEIVER")

config :certificate_check, :api_resolvers,
  email_sender: CertificateCheck.EmailSender

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
