use Mix.Config

config :ocsp_service, ecto_repos: [OCSPService.Repo]

config :ocsp_service, OCSPService.Repo, database: "ocsp_service_dev"
