defmodule API.Web.APIController do
  @moduledoc false

  use API.Web, :controller
  use JValid
  alias API.ContentDecoder
  require Logger

  action_fallback(API.Web.FallbackController)

  use_schema(
    :digital_signatures,
    "specs/json_schemas/digital_signatures_request.json"
  )

  def index(conn, params) do
    with :ok <- validate_schema(:digital_signatures, params),
         {:ok, result} <- ContentDecoder.decode(Map.get(params, "signed_content")) do
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
