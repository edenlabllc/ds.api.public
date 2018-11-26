defmodule Core.Repo.Migrations.ContentToText do
  use Ecto.Migration

  def change do
    execute("
    ALTER TABLE invalid_content ALTER COLUMN content TYPE text USING convert_from(content, 'UTF8');
    ")
  end
end
