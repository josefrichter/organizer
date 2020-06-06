defmodule Todolists.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :list_id, :string
      add :text, :string
      add :done, :boolean, default: false, null: false

      timestamps()
    end

  end
end
