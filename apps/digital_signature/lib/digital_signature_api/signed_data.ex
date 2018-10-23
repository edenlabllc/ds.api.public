defmodule DigitalSignature.SignedData do
  @moduledoc false
  alias __MODULE__
  defstruct(signatures: [], content: "")

  def new, do: %__MODULE__{}

  def update(%SignedData{signatures: signatures}, %{
        signer: signer,
        is_stamp: is_stamp,
        is_valid: is_valid,
        validation_error_message: validation_error_message,
        content: content
      })
      when is_map(signer) and is_boolean(is_valid) and is_bitstring(validation_error_message) and is_binary(content) do
    signature = %{
      signer: signer,
      is_stamp: is_stamp,
      is_valid: is_valid,
      validation_error_message: validation_error_message
    }

    %SignedData{signatures: signatures ++ [signature], content: content}
  end

  def add_sign_error(
        %SignedData{signatures: signatures, content: content},
        error_message
      )
      when is_bitstring(error_message) do
    signature = %{
      signer: %{},
      is_valid: false,
      validation_error_message: error_message
    }

    %SignedData{signatures: signatures ++ [signature], content: content}
  end

  def get_map(%SignedData{} = signed_data), do: Map.from_struct(signed_data)
end
