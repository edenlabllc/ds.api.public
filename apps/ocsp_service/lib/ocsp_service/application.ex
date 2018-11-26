defmodule OCSPService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Confex, otp_app: :ocsp_service
  import Supervisor.Spec, warn: false

  alias OCSPService.ReChecker

  def start(_type, _args) do
    gen_consumer_impl = OCSPService.Kafka.GenConsumer

    consumer_group_name = Application.fetch_env!(:kafka_ex, :consumer_group)

    topic_names = ["digital_signature"]

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    recheck_timeout = config()[:recheck_policy][:recheck_timeout]
    max_recheck_tries = config()[:recheck_policy][:max_recheck_tries]

    children = [
      %{
        id: ReChecker,
        start: {ReChecker, :start_link, [{recheck_timeout, max_recheck_tries}]}
      },
      supervisor(KafkaEx.ConsumerGroup, [
        gen_consumer_impl,
        consumer_group_name,
        topic_names,
        consumer_group_opts
      ])
    ]

    opts = [strategy: :one_for_one, name: OCSPService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
