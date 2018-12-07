defmodule Core.InvalidContents do
  @moduledoc """
  Encodes data of certificates to base64 to be able Jason.encode
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Core.InvalidContent
  alias Core.Repo
  alias Ecto.Changeset

  def update_invalid_content(id, params) do
    with %InvalidContent{} = invalid_content <- get_by_id(id),
         %Changeset{valid?: true} = changeset <-
           changeset(invalid_content, params) do
      {:ok, _} = Repo.update(changeset)
    end
  end

  def store_invalid_content(signatures, content) do
    encoded_signatures =
      Enum.reduce(signatures, [], fn signature, acc ->
        encoded_signatures_data =
          signature
          |> Map.take(~w(data root_data ocsp_data)a)
          |> Enum.reduce(%{}, fn {k, data}, acc ->
            Map.put(acc, k, Base.encode64(data))
          end)

        [
          signature
          |> Map.take(~w(access crl delta_crl serial_number)a)
          |> Map.merge(encoded_signatures_data)
          | acc
        ]
      end)

    encoded_content =
      case Jason.encode(content) do
        {:ok, content_data} -> content_data
        _ -> content
      end

    {:ok, %InvalidContent{id: id}} =
      %InvalidContent{}
      |> changeset(%{
        signatures: encoded_signatures,
        content: encoded_content
      })
      |> Repo.insert(returning: [:id])

    {:ok, id}
  end

  def get_by_id(id) do
    InvalidContent
    |> Repo.get_by(id: id)
    |> invalid_content()
  end

  def delete(id) do
    %InvalidContent{id: id}
    |> Repo.delete()
  end

  def random_invalid_content do
    InvalidContent
    |> where([i], is_nil(i.notified) or i.notified == ^false)
    |> limit(1)
    |> Repo.one()
    |> invalid_content()
  end

  def stored_invalid_content do
    InvalidContent
    |> where([i], is_nil(i.notified) or i.notified == ^false)
    |> Repo.all()
    |> Enum.map(&invalid_content/1)
  end

  defp invalid_content(invalid_content) do
    with %InvalidContent{
           id: id,
           signatures: encoded_signatures,
           content: content,
           inserted_at: inserted_at,
           updated_at: updated_at,
           received: received,
           notified: notified
         } <- invalid_content do
      signatures =
        Enum.reduce(encoded_signatures, [], fn signature, acc ->
          decoded_signatures_data =
            signature
            |> Map.take(~w(data root_data ocsp_data))
            |> Enum.reduce(%{}, fn {k, data}, acc ->
              Map.put(acc, k, Base.decode64!(data))
            end)

          [
            signature
            |> Map.take(~w(access crl delta_crl serial_number))
            |> Map.merge(decoded_signatures_data)
            |> Enum.reduce(%{}, fn {k, v}, acc ->
              Map.put(acc, :erlang.binary_to_atom(k, :utf8), v)
            end)
            | acc
          ]
        end)

      %InvalidContent{
        id: id,
        signatures: signatures,
        content: content,
        inserted_at: inserted_at,
        updated_at: updated_at,
        received: received,
        notified: notified
      }
    end
  end

  defp changeset(%InvalidContent{} = invalid_content, attrs) do
    invalid_content
    |> cast(attrs, [:signatures, :content, :notified, :received])
  end
end
