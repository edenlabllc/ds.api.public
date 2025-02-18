defmodule Core.Repo.Migrations.AddCrlTables do
  use Ecto.Migration

  def up do
    # crl url info
    create table(:crl, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:url, :string, null: false)
      add(:next_update, :utc_datetime, null: false)
    end

    create(unique_index(:crl, [:url]))

    # revoked serial numbers
    create table(:revoked, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:url, :string, null: false)
      add(:serial_number, :string, null: false)
    end

    create(index(:revoked, [:url, :serial_number]))
  end

  def down do
    drop(table(:crl))
    drop(table(:revoked))
  end
end
