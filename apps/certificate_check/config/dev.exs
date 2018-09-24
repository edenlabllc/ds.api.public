use Mix.Config

config :certificate_check,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 2}
  ]

config :certificate_check, ecto_repos: [CertificateCheck.Repo]

config :certificate_check, CertificateCheck.Repo,
  database: "certificate_check_dev"
