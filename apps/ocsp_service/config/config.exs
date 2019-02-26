use Mix.Config

config :ocsp_service, namespace: OCSPService

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

config :ocsp_service, OCSPService.ReChecker,
  recheck_policy: [
    start: {:system, :boolean, "START_RECHECK", true},
    recheck_timeout: {:system, :integer, "RECHEK_TIMEOUT", 300_000},
    max_recheck_tries: {:system, :integer, "MAX_RECHEK_TRIES", 12}
  ]

config :ocsp_service,
  kaffe_consumer: [
    endpoints: {:system, :string, "KAFKA_BROKERS"},
    topics: ["digital_signature"],
    consumer_group: {:system, :string, "CONSUMER_GROUP"},
    message_handler: OCSPService.Kafka.GenConsumer
  ]

import_config "#{Mix.env()}.exs"
