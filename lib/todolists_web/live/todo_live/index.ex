defmodule TodolistsWeb.TodoLive.Index do
  use TodolistsWeb, :live_view

  alias Todolists.TodoLists
  alias Todolists.TodoLists.Todo

  @impl true
  def mount(%{"list_id" => list_id}, _session, socket) do
    socket = 
      socket 
      |> assign(:todos, list_todos(list_id))
      |> assign(:list_id, list_id)
    {:ok, socket}
  end

  # match no slug -> create one
  def mount(%{}, _session, socket) do
    new_list_id = MnemonicSlugs.generate_slug(3)
    socket = 
      socket 
      |> assign(:list_id, new_list_id)
      |> assign(:todos, list_todos(new_list_id)) # shall be always empty
    {:ok, push_redirect(socket, to: "/#{new_list_id}")}
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

  defp apply_action(socket, :new, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{list_id: list_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id, "listid" => list_id} = params, socket) do
    # the delete event is unable to send parameter "list_id", so I'm sending "listid" (only here)
    todo = TodoLists.get_todo!(id)
    {:ok, _} = TodoLists.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos(list_id))}
  end

  def handle_event("toggle", %{"id" => id, "list_id" => list_id} = params, socket) do
    todo = TodoLists.get_todo!(id)
    update_response = 
      TodoLists.update_todo(todo, %{done: !todo.done})
    case update_response do
      {:ok, _todo} -> 
        socket = assign(socket, :todos, list_todos(list_id))
      {:error, changeset} ->
        socket 
         |> put_flash(:error, "Error: #{changeset.errors}")
    end

    if list_completed?(list_id) do # TODO async
      # TODO fine-tune this
      # Todolists.Mailer.send_completion_notification("josef.richter@me.com")  
    end

    {:noreply, socket}
  end

  defp list_todos do
    TodoLists.list_todos()
  end

  defp list_todos(list_id) do
    TodoLists.list_todos(list_id)
  end

  defp list_completed?(list_id) do
    TodoLists.list_todos(list_id)
    |> Enum.all?(&(&1.done)) # checks if all true https://hexdocs.pm/elixir/Enum.html#all?/2
  end

end
