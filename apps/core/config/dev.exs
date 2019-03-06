use Mix.Config

config :core, Core.Repo,
  database: "ds_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 10,
  timeout: 15_000
