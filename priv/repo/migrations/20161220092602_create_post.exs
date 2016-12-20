defmodule Sulat.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :text, :text
      add :title, :string

      timestamps()
    end

  end
end
