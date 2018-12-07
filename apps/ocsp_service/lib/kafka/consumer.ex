defmodule OCSPService.Kafka.GenConsumer do
  @moduledoc false
  use KafkaEx.GenConsumer

  alias Core.InvalidContents
  alias DigitalSignature.NifServiceAPI
  alias KafkaEx.Protocol.Fetch.Message
  alias OCSPService.ReChecker

  require Logger

  # note - messages are delivered in batches
  def handle_message_set(message_set, state) do
    for %Message{value: message, offset: offset} <- message_set do
      with %{signatures: signatures, content: content} <-
             :erlang.binary_to_term(message) do
        online_check_signed_content(signatures, content)
      else
        _ ->
          Logger.error(
            "Unhandled message: #{inspect(message)}, offset: #{offset}"
          )
      end
    end

    {:async_commit, state}
  end

  def online_check_signed_content(signatures, content) do
    if not NifServiceAPI.signatures_valid_online?(signatures) do
      {:ok, id} = InvalidContents.store_invalid_content(signatures, content)
      send(ReChecker, {:recheck, ReChecker, id, 0, signatures})
    end
  end
end
