defmodule CertificateCheck.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    gen_consumer_impl = CertificateCheck.Kafka.GenConsumer
    consumer_group_name = "digital_signature"
    topic_names = ["signatures"]

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    children = [
      CertificateCheck.Repo,
      supervisor(KafkaEx.ConsumerGroup, [
        gen_consumer_impl,
        consumer_group_name,
        topic_names,
        consumer_group_opts
      ])
    ]

    opts = [strategy: :one_for_one, name: CertificateCheck.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
