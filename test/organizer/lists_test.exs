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

  describe "users" do
    alias Organizer.Lists.User

    @valid_attrs %{email: "some email", list_id: "some list_id"}
    @update_attrs %{email: "some updated email", list_id: "some updated list_id"}
    @invalid_attrs %{email: nil, list_id: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Lists.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Lists.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Lists.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Lists.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.list_id == "some list_id"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lists.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Lists.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.list_id == "some updated list_id"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Lists.update_user(user, @invalid_attrs)
      assert user == Lists.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Lists.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Lists.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Lists.change_user(user)
    end
  end
end
