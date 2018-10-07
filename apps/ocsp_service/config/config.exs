use Mix.Config

config :ocsp_service,
  namespace: OCSPService,
  kafka: [
    consumer: OCSPService.Kafka.Consumer,
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10},
    topic: {:system, "DS_KAFKA_TOPIC", "digital_signature"}
  ]

config :ocsp_service, OCSPService.EmailSender,
  relay: {:system, "SMTP_RELAY"},
  username: {:system, "SMTP_USERNAME"},
  password: {:system, "SMTP_PASSWORD"},
  warning_receiver: {:system, "SMTP_WARNING_RECEIVER"}

config :ocsp_service, :api_resolvers, email_sender: OCSPService.EmailSender

import_config "#{Mix.env()}.exs"
