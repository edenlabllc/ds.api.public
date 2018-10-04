use Mix.Config

config :ocsp_service, sql_sandbox: true

config :ocsp_service, ecto_repos: [OCSPService.Repo]

config :ocsp_service, OCSPService.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test"

config :ocsp_service, :api_resolvers, email_sender: EmailSenderMock
