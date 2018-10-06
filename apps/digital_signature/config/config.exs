use Mix.Config

# General application configuration
config :digital_signature,
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

import_config("#{Mix.env()}.exs")
