defmodule Core.Repo.Migrations.DropRevoked do
  use Ecto.Migration

  def change do
    drop(table(:revoked))
  end
end
