defmodule Organizer.Lists.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :list_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:list_id, :email])
    |> validate_required([:list_id, :email])
  end
end
