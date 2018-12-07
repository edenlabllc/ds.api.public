use Mix.Config

config :ocsp_service, :api_resolvers, email_sender: EmailSenderMock

config :ocsp_service, OCSPService.ReChecker,
  recheck_policy: [
    start: {:system, :boolean, "START_RECHECK", false},
    recheck_timeout: {:system, :integer, "RECHEK_TIMEOUT", 0},
    max_recheck_tries: {:system, :integer, "MAX_RECHEK_TRIES", 1}
  ]
