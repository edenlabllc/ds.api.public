defmodule Core.Repo.Migrations.KafkaTopic do
  use Ecto.Migration

  def change do
    Application.ensure_started(:kafka_ex)
    partitions = Confex.fetch_env!(:core, :kafka)[:partitions]
    topic = "digital_signature"

    request = %{
      topic: topic,
      num_partitions: partitions,
      replication_factor: 1,
      replica_assignment: [],
      config_entries: []
    }

    KafkaEx.create_topics([request], timeout: 2000)
  end
end
