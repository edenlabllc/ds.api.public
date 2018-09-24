defmodule DigitalSignature.DigitalSignatureLibBehaviour do
  @moduledoc false
  @callback checkPKCS7Data(signed_content :: binary) ::
              {:ok, result :: term}
              | {:error, reason :: term}

  @callback retrivePKCS7Data(
              signed_content :: binary,
              certs :: list,
              check :: boolean
            ) ::
              {:ok, data :: binary, providers_info :: list}
              | {:error, reason :: term}
end
