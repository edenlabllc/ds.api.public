defmodule OCSPService.EmailSender do
  @moduledoc """
  send email via smtp server
  """

  @behaviour OCSPService.EmailSenderBehaviour

  def send(id) do
    relay = Confex.fetch_env!(:ocsp_service, __MODULE__)[:relay]
    username = Confex.fetch_env!(:ocsp_service, __MODULE__)[:username]
    password = Confex.fetch_env!(:ocsp_service, __MODULE__)[:password]

    warning_receivers =
      Confex.fetch_env!(:ocsp_service, __MODULE__)[:warning_receivers]

    :gen_smtp_client.send(
      {username, warning_receivers,
       "Subject: Invalid Digital Signature\r\nFrom: ds.api \r\nTo: Ehealth support team \r\n\r\nInvalid signatured content was accepted, id: #{
         id
       }"},
      relay: relay,
      username: username,
      password: password
    )
  end
end
