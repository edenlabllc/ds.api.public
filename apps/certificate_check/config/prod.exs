use Mix.Config

config :certificate_check,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10}
  ]
