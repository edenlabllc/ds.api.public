use Mix.Config

config :ocsp_service,
  namespace: OCSPService,
  kafka: [
    consumer: OCSPService.Kafka.Consumer,
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10},
    topic: {:system, "DS_KAFKA_TOPIC", "digital_signature"}
  ]

config :ocsp_service, OCSPService.EmailSender,
  endpoint: {:system, "EHEALTH_EMAIL_ENDPOINT"},
  sender: {:system, "SENDER"},
  template_id: {:system, :integer, "TEMPLATE_ID"},
  warning_receivers: {:system, "SMTP_WARNING_RECEIVERS"},
  hackney_options: [
    connect_timeout: {:system, :integer, "OCSP_SERVICE_REQUEST_TIMEOUT", 5000},
    recv_timeout: {:system, :integer, "OCSP_SERVICE_REQUEST_TIMEOUT", 5000},
    timeout: {:system, :integer, "OCSP_SERVICE_REQUEST_TIMEOUT", 5000}
  ]

config :ocsp_service, :api_resolvers, email_sender: OCSPService.EmailSender

config :kafka_ex,
  brokers: System.get_env("KAFKA_BROKERS"),
  consumer_group: System.get_env("CONSUMER_GROUP"),
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  commit_interval: 5_000,
  auto_offset_reset: :earliest,
  commit_threshold: 100,
  kafka_version: "1.1.0"

import_config "#{Mix.env()}.exs"
