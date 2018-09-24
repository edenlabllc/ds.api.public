defmodule Core.Crl do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "crl" do
    field(:url, :string)
    field(:next_update, :utc_datetime)
  end
end
