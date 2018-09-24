defmodule DigitalSignature.Kafka.Producer do
  @moduledoc false

  require Logger

  @digital_signature_topic "digital_signature"
  @behaviour DigitalSignature.Behaviours.KafkaProducerBehaviour

  def publish_sigantures(%{signatures: _signaures, content: _content} = certificates_info) do
    partitions = Confex.fetch_env!(:digital_signature, :kafka)[:partitions]

    data = :erlang.term_to_binary(certificates_info)

    :ok =
      KafkaEx.produce(
        @digital_signature_topic,
        Enum.random(0..(partitions - 1)),
        data
      )
  end

  def publish_sigantures(error),
    do: Logger.error("Wait for a map with :signatures, :content keys, received: #{inspect(error)}")
end
