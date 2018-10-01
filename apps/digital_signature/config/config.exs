use Mix.Config

# General application configuration
config :digital_signature,
  ecto_repos: [Core.Repo],
  namespace: DigitalSignature,
  call_response_threshold: {:system, :integer, "CALL_RESPONSE_THRESHOLD", 100},
  certs_cache_ttl: {:system, :integer, "CERTS_CACHE_TTL", 30 * 60 * 1000},
  service_call_timeout: {:system, :integer, "SERVICE_CALL_TIMEOUT", 5000},
  ocs_timeout: {:system, :integer, "OCS_CALL_TIMEOUT", 1000},
  api_resolvers: [digital_signature: DigitalSignature.DigitalSignatureLib],
  kafka: [
    producer: DigitalSignature.Kafka.Producer,
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10},
    topic: {:system, "DS_KAFKA_TOPIC", "digital_signature"}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

config :phoenix, :format_encoders, json: Jason

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

import_config("#{Mix.env()}.exs")
