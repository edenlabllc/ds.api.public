defmodule CertificateCheck.EmailSender do
  @moduledoc """
  send email via smtp server
  """

  @behaviour CertificateCheck.EmailSenderBehaviour

  def send(id) do
    relay = Confex.fetch_env!(:certificate_check, __MODULE__)[:relay]
    username = Confex.fetch_env!(:certificate_check, __MODULE__)[:username]
    password = Confex.fetch_env!(:certificate_check, __MODULE__)[:password]

    warning_receiver =
      Confex.fetch_env!(:certificate_check, __MODULE__)[:warning_receiver]

    :gen_smtp_client.send(
      {username, [warning_receiver],
       "Subject: Invalid Digital Signature\r\nFrom: ds.api \r\nTo: Ehealth support team \r\n\r\nInvalid signatured content was accepted, id: #{
         id
       }"},
      relay: relay,
      username: username,
      password: password
    )
  end
end
