use Mix.Config

config :ocsp_service,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 2}
  ]

config :ocsp_service, ecto_repos: [OCSPService.Repo]

config :ocsp_service, OCSPService.Repo, database: "ocsp_service_dev"
