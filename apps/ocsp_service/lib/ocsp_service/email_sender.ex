defmodule OCSPService.EmailSender do
  @moduledoc """
  send email via smtp server
  """

  use OCSPService.API.Helpers.MicroserviceBase

  @behaviour OCSPService.SenderBehaviour

  def send(id) do
    template_id = Confex.fetch_env!(:ocsp_service, __MODULE__)[:template_id]
    sender = Confex.fetch_env!(:ocsp_service, __MODULE__)[:sender]

    warning_receivers = Confex.fetch_env!(:ocsp_service, __MODULE__)[:warning_receivers]

    params = %{
      subject: "Invalid Digital Signature",
      from: sender,
      to: warning_receivers,
      invalid_content_id: id,
      data: %{}
    }

    headers = []
    post!("/internal/email/#{template_id}", Jason.encode!(params), headers)
  end
end
