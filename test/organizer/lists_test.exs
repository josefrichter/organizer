defmodule Organizer.ListsTest do
  use Organizer.DataCase

  alias Organizer.Lists

  describe "todos" do
    alias Organizer.Lists.Todo

    @valid_attrs %{done: true, list_id: "some list_id", text: "some text"}
    @update_attrs %{done: false, list_id: "some updated list_id", text: "some updated text"}
    @invalid_attrs %{done: nil, list_id: nil, text: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Lists.create_todo()

      todo
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Lists.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Lists.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Lists.create_todo(@valid_attrs)
      assert todo.done == true
      assert todo.list_id == "some list_id"
      assert todo.text == "some text"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lists.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Lists.update_todo(todo, @update_attrs)
      assert todo.done == false
      assert todo.list_id == "some updated list_id"
      assert todo.text == "some updated text"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Lists.update_todo(todo, @invalid_attrs)
      assert todo == Lists.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Lists.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Lists.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Lists.change_todo(todo)
    end
  end
end
