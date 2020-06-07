defmodule Todolists.Repo.Migrations.AddListIdIndex do
  use Ecto.Migration

  def change do
    create index("todos", [:list_id])
  end
  
end
