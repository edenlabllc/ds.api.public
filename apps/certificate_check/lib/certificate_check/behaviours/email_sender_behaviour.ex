defmodule CertificateCheck.EmailSenderBehaviour do
  @moduledoc false
  @callback send(id :: binary) :: term
end
