use Mix.Config

config :certificate_check, sql_sandbox: true

config :certificate_check, ecto_repos: [CertificateCheck.Repo]

config :certificate_check, CertificateCheck.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "certificate_check_test"

config :certificate_check, :api_resolvers, email_sender: EmailSenderMock
