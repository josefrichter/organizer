defmodule TodolistsWeb.TodoLive.Index do
  use TodolistsWeb, :live_view

  alias Todolists.TodoLists
  alias Todolists.TodoLists.Todo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, TodoLists.get_todo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = TodoLists.get_todo!(id)
    {:ok, _} = TodoLists.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos())}
  end

  def handle_event("toggle", %{"id" => id} = params, socket) do
    IO.inspect params
    todo = TodoLists.get_todo!(id)
    update_response = 
      TodoLists.update_todo(todo, %{done: !todo.done})
    case update_response do
      {:ok, _todo} -> 
        socket = assign(socket, :todos, list_todos())
      {:error, changeset} ->
        socket 
         |> put_flash(:error, "Error: #{changeset.errors}")
    end
    {:noreply, socket}
  end

  defp list_todos do
    TodoLists.list_todos()
  end
end
