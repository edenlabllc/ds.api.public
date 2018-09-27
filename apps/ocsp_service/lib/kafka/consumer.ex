defmodule OCSPService.Kafka.GenConsumer do
  @moduledoc false
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message
  alias OCSPService.InvalidContents
  alias OCSPService.Notifier

  require Logger

  # note - messages are delivered in batches
  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      with %{signatures: signatures, content: content} <-
             :erlang.binary_to_term(message) do
        {:ok, _id} = InvalidContents.store_invalid_content(signatures, content)
        :ok
      else
        _ -> Logger.error("Unhandled message: #{inspect(message)}")
      end
    end

    GenServer.cast(Notifier, :invalid_sign)

    {:async_commit, state}
  end
end
