defmodule OCSPService.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  alias OCSPService.ReChecker

  def start(_type, _args) do
    gen_consumer_impl = OCSPService.Kafka.GenConsumer

    consumer_group_name = System.get_env("CONSUMER_GROUP")

    topic_names = ["digital_signature"]

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    children = [
      %{
        id: ReChecker,
        start: {ReChecker, :start_link, []}
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
