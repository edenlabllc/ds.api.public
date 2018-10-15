defmodule OCSPService.Kafka.GenConsumer do
  @moduledoc false
  use KafkaEx.GenConsumer

  alias Core.InvalidContents
  alias DigitalSignature.NifServiceAPI
  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  @email_sender Application.get_env(:ocsp_service, :api_resolvers)[
                  :email_sender
                ]

  @timeout 5000

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
    expires_at =
      NaiveDateTime.add(
        NaiveDateTime.utc_now(),
        @timeout,
        :millisecond
      )

    if Enum.any?(signatures, fn %{
                                  access: url,
                                  data: data,
                                  ocsp_data: ocsp_data
                                } ->
         {:ok, false} ==
           NifServiceAPI.check_online(
             url,
             data,
             ocsp_data,
             expires_at,
             @timeout
           )
       end) do
      {:ok, id} = InvalidContents.store_invalid_content(signatures, content)
      @email_sender.send(id)
    end
  end
end
