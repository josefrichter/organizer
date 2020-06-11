defmodule OrganizerWeb.TodoLive.Index do
  use OrganizerWeb, :live_view

  alias Organizer.Lists
  alias Organizer.Lists.Todo
  alias Organizer.Lists.User

  @impl true
  def mount(%{"list_id" => list_id}, _session, socket) do
    socket = 
      socket 
      |> assign(:todos, list_todos(list_id))
      |> assign(:list_id, list_id)
      |> assign(:user, get_user(list_id))
    if connected?(socket), do: Process.send_after(self(), :clear_flash, 3000)
    {:ok, socket}
  end

  # match no slug -> create one
  def mount(%{}, _session, socket) do
    new_list_id = MnemonicSlugs.generate_slug(3)
    socket = 
      socket 
      |> assign(:list_id, new_list_id)
      |> assign(:todos, list_todos(new_list_id)) # shall be always empty
      |> assign(:user, nil) # empty user
    {:ok, push_redirect(socket, to: "/#{new_list_id}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect(self(), label: "handle params")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Lists.get_todo!(id))
  end

  defp apply_action(socket, :new, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{list_id: list_id})
  end

  defp apply_action(socket, :add_user, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "Add User")
    |> assign(:user, %User{list_id: list_id})
    |> assign(:list_id, list_id)
  end

  defp apply_action(socket, :edit_user, %{"id" => id} = params) do
    IO.inspect id
    IO.inspect Lists.get_user!(id)
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Lists.get_user!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id, "listid" => list_id} = params, socket) do
    # the delete event is unable to send parameter "list_id", so I'm sending "listid" (only here)
    todo = Lists.get_todo!(id)
    {:ok, _} = Lists.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos(list_id))}
  end

  def handle_event("toggle", %{"id" => id, "list_id" => list_id} = params, socket) do
    todo = Lists.get_todo!(id)
    update_response = 
      Lists.update_todo(todo, %{done: !todo.done})
    socket =
      case update_response do
        {:ok, _todo} -> 
          socket = assign(socket, :todos, list_todos(list_id))
        {:error, changeset} ->
          socket 
          |> put_flash(:error, "Error: #{changeset.errors}")
      end

    IO.puts "Checking if all tasks completed..."
    if (socket.assigns.user && list_completed?(socket.assigns.list_id)) do
      email = socket.assigns.user.email
      list_id = socket.assigns.list_id

      send_completion_notification(email, list_id)

      IO.puts "All tasks complete!"

      put_flash(socket, :info, "All tasks complete! Sending notification to #{email}...")
    else
      IO.puts "Nope, either no user, or list not complete yet..."

      socket
    end 

    {:noreply, socket}
  end

  defp send_completion_notification(email, list_id) do
    Task.Supervisor.start_child(Organizer.TaskSupervisor, fn ->
      IO.puts "Sending to #{email} from within a Task"
      list_url = "https://organizer.gigalixirapp.com/#{list_id}"
      Organizer.Mailer.send_completion_notification(email, list_url)
    end)
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp list_todos do
    Lists.list_todos()
  end

  defp list_todos(list_id) do
    Lists.list_todos(list_id)
  end

  defp get_user(list_id) do
    Lists.get_user_by_list_id(list_id)
  end

  defp list_completed?(list_id) do
    Lists.list_todos(list_id)
    |> Enum.all?(&(&1.done)) # checks if all true https://hexdocs.pm/elixir/Enum.html#all?/2
  end

end
