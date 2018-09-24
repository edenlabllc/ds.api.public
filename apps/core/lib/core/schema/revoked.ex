defmodule Core.RevokedSN do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "revoked" do
    field(:url, :string)
    field(:serial_number, :string)
  end
end
