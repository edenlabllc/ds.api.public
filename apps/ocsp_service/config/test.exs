use Mix.Config

config :ocsp_service, sql_sandbox: true

# Database Configuration
config :core, OCSPService.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  port: 5432,
  ownership_timeout: 120_000_000

config :ocsp_service, :api_resolvers, email_sender: EmailSenderMock
