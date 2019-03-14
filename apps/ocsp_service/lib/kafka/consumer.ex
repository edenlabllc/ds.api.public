defmodule OCSPService.Kafka.GenConsumer do
  @moduledoc false

  alias Core.InvalidContents
  alias DigitalSignature.NifServiceAPI
  alias OCSPService.ReChecker

  require Logger

  # note - messages are delivered in batches
  def handle_messages(messages) do
    for %{value: value, offset: offset} <- messages do
      with %{signatures: signatures, content: content} <-
             :erlang.binary_to_term(value) do
        online_check_signed_content(signatures, content)
      else
        _ ->
          Logger.error("Unhandled message: #{inspect(value)}, offset: #{offset}")
      end
    end

    :ok
  end

  def online_check_signed_content(signatures, content) do
    if not NifServiceAPI.signatures_valid_online?(signatures) do
      {:ok, id} = InvalidContents.store_invalid_content(signatures, content)
      send(ReChecker, {:recheck, ReChecker, id, 0, signatures})
    end
  end
end
