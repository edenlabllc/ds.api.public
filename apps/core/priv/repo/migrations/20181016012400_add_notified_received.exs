defmodule Core.Repo.Migrations.AddNotifiedReceived do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    alter table(:invalid_content) do
      add(:notified, :boolean)
      add(:received, :boolean)
    end
  end
end
