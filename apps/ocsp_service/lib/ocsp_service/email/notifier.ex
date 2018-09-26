defmodule OCSPService.Notifier do
  @moduledoc """
  Recheck signatures and
  send email with notificates about content invalid signed
  in case offline check mark signature as valid
  but signature is not valid
  """

  alias OCSPService.InvalidContent
  alias OCSPService.InvalidContents
  alias DigitalSignature.NifServiceAPI

  @email_sender Application.get_env(:ocsp_service, :api_resolvers)[
                  :email_sender
                ]

  @timeout 5000

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_), do: {:ok, %{}}

  def handle_cast(:invalid_sign, state) do
    {:noreply, state}
  end

  def send_notification do
  end

  def process_invalid_sign do
    with %InvalidContent{id: id, signatures: signatures} <-
           InvalidContents.random_invalid_content() do
      expires_at =
        NaiveDateTime.add(
          NaiveDateTime.utc_now(),
          @timeout,
          :millisecond
        )

      # recheck signatures invalid
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
        @email_sender.send(id)
      else
        # signatures valid
        InvalidContents.delete(id)
      end
    end

    GenServer.cast(__MODULE__, :invalid_sign)
  end
end
