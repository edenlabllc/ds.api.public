defmodule OCSPService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    gen_consumer_impl = OCSPService.Kafka.GenConsumer

    consumer_group_name =
      Confex.fetch_env!(:ocsp_service, :kafka)[:consumer_group]

    topic_names = [Confex.fetch_env!(:ocsp_service, :kafka)[:topic]]

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    children = [
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
