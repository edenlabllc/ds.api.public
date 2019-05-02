defmodule API.ContentDecoder do
  @moduledoc false

  alias DigitalSignature.NifAPI
  require Logger

  def decode(signed_content) do
    with {:ok, signed_content} <- Base.decode64(signed_content),
         {:ok, result} <- NifAPI.process_signed_content(signed_content, true) do
      {:ok, result}
    else
      :error ->
        error = [
          {%{description: "Not a base64 string", params: [], rule: :invalid}, "$.signed_content"}
        ]

        Logger.error(inspect(error))
        {:error, error}

      {:error, errors} when is_list(errors) ->
        Enum.each(errors, &Logger.error(inspect(&1)))
        {:error, errors}

      {:error, error} ->
        Logger.error(inspect(error))
        {:error, error}
    end
  end
end
