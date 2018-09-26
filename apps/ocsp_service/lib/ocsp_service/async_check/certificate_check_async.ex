defmodule OCSPService.AsyncSign do
  @moduledoc """
  OCSP rfc 2560
  """

  @doc """
  Elixir implementation rfc2560
  Use it when dsszzi.gov.ua certificate ds.api
  """
  def ocsp_rfc250(access, data, timeout \\ 2000) do
    case HTTPoison.post(
           access,
           data,
           [{"Content-Type", "application/ocsp-request"}],
           timeout: timeout
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # TODO: implement rfc asn.1 OCSPResponse check
        # make separate erlanf dep and than use erlang 'OCSP' module
        with {:ok, {_, _, {_, T, R}}} <- OCSP.decode('OCSPResponse', body),
             _ <- OCSP.decode('OCSPResponse', R) do
          {:ok, true}
        else
          _ ->
            {:error, :decode}
        end

      {:error, %HTTPoison.Error{reason: :connect_timeout}} ->
        {:ok, :timeout}

      _ ->
        {:error, :invalid}
    end
  end
end
