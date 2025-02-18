defmodule OCSPService.API.Helpers.ResponseDecoder do
  @moduledoc """
  HTTPPoison JSON to Elixir data decoder and formatter
  """

  @success_codes [200, 201, 204]

  def check_response({:ok, %HTTPoison.Response{} = response}),
    do: check_response(response)

  def check_response(%HTTPoison.Response{status_code: status_code, body: body})
      when status_code in @success_codes do
    decode_response(body)
  end

  def check_response(%HTTPoison.Response{status_code: code, body: ""}),
    do: {:error, {:empty_body, code}}

  def check_response(%HTTPoison.Response{body: body}) do
    case decode_response(body) do
      {:ok, body} -> {:error, body}
      err -> err
    end
  end

  # no body in response
  def decode_response(""), do: {:ok, ""}

  def decode_response(response) do
    case Jason.decode(response) do
      {:ok, body} -> {:ok, body}
      _ -> {:error, {:response_json_decoder, response}}
    end
  end
end
