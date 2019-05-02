defmodule API.Rpc do
  @moduledoc """
  This module contains functions that are called from other pods via RPC.
  """

  alias API.ContentDecoder
  alias API.Web.APIView

  @type signer() :: %{
          drfo: binary(),
          edrpou: binary(),
          surname: binary(),
          given_name: binary()
        }

  @type signature() :: %{
          is_valid: boolean(),
          validation_error_message: binary(),
          signer: signer(),
          is_stamp: boolean()
        }

  @type result() :: %{
          signatures: list(signature),
          content: map
        }

  @doc """
  Decode signed content

  ## Examples

      iex> API.Rpc.decode_signed_content("...")
      {:ok,
        %{
          content: %{"text" => "Hello World"},
          signatures: [
            %{
              is_stamp: false,
              is_valid: true,
              signer: %{
                common_name: "...",
                country_name: "UA",
                drfo: "...",
                edrpou: "...",
                given_name: "...",
                locality_name: "Київ",
                organization_name: "",
                organizational_unit_name: "",
                state_or_province_name: "",
                surname: "...",
                title: "директор"
              },
              validation_error_message: ""
            }
          ]
        }}
  """
  @spec decode_signed_content(signed_content :: binary) :: {:ok, result} | {:error, any}
  def decode_signed_content(signed_content) do
    with {:ok, result} <- ContentDecoder.decode(signed_content) do
      {:ok, APIView.render("show.json", %{digital_signature_info: result})}
    end
  end
end
