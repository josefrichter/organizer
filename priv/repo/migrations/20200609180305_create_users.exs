defmodule Organizer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :list_id, :string
      add :email, :string

      timestamps()
    end
  end
end
