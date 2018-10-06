use Mix.Config

config :kafka_ex,
  brokers: "${KAFKA_BROKERS}",
  consumer_group: "${CONSUMER_GROUP}"
