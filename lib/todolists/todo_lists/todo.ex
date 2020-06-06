defmodule Todolists.TodoLists.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :done, :boolean, default: false
    field :list_id, :string
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:list_id, :text, :done])
    |> validate_required([:list_id, :text, :done])
  end
end
