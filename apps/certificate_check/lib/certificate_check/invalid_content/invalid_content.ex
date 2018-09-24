defmodule CertificateCheck.InvalidContent do
  @moduledoc """
  table with invalid content and signatures for content
  Content can be either json or base64 data
  (It depends how much signatures is on content and level of invalid sign)
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "invalid_content" do
    field(:signatures, {:array, :map})
    field(:content, :binary)

    timestamps()
  end
end
