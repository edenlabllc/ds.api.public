use Mix.Config

config :kafka_ex,
  brokers: {:system, "KAFKA_BROKERS"},
  consumer_group: {:system, "CONSUMER_GROUP"}
