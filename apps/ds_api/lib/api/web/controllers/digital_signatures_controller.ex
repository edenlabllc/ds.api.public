defmodule API.Web.APIController do
  @moduledoc false
  use API.Web, :controller
  use JValid
  alias DigitalSignature.NifAPI
  require Logger

  action_fallback(API.Web.FallbackController)

  use_schema(
    :digital_signatures,
    "specs/json_schemas/digital_signatures_request.json"
  )

  def index(conn, params) do
    with :ok <- validate_schema(:digital_signatures, params),
         {:ok, signed_content} <- Base.decode64(Map.get(params, "signed_content")),
         {:ok, result} <- NifAPI.process_signed_content(signed_content, params["check"] || true) do
      render_response(result, conn)
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

  defp render_response(result, conn) do
    render(conn, "show.json", digital_signature_info: result)
  end
end
