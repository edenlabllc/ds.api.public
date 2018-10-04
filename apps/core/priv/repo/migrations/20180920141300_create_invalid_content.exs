defmodule Core.Repo.Migrations.CreateInvalidContent do
  use Ecto.Migration

  def change do
    create table(:invalid_content, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:signatures, :jsonb, null: false)
      add(:content, :binary, null: false)

      timestamps()
    end
  end
end
