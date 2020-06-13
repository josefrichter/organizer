defmodule OrganizerWeb.TodoLive.Index do
  use OrganizerWeb, :live_view

  alias Organizer.Lists
  alias Organizer.Lists.Todo
  alias Organizer.Lists.User

  @impl true
  @doc"""
  Mount function for "/any-new-slug"
  Will assign all todos for given slug
  Will assign user email for given slug, if any
  """
  def mount(%{"list_id" => list_id}, _session, socket) do
    socket = 
      socket 
      |> assign(:todos, list_todos(list_id))
      |> assign(:user, get_user(list_id))
      |> assign(:list_id, list_id)
    # clearing whichever flash message, after 3 seconds
    if connected?(socket), do: Process.send_after(self(), :clear_flash, 3000)
    # temporary assign for push_patch, 
    # not sure if needed when phx-update="replace" in the template
    # {:ok, socket, temporary_assigns: [todos: []]} 
    {:ok, socket}
  end

  @doc"""
  When "/" is reached, a new random slug is generated
  followed by redirect to "/the-new-slug"
  """
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

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Todo")
  #   |> assign(:todo, Lists.get_todo!(id))
  # end

  @doc"""
  Prepare socket for creating new Todo
  """
  defp apply_action(socket, :new, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "New Todo")
    # create empty Todo, pre-filled with list_id (hidden field in form)
    |> assign(:todo, %Todo{list_id: list_id})
  end

  @doc"""
  Adding user (email) to be notified when list_id is complete
  """
  defp apply_action(socket, :add_user, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "Add User")
    |> assign(:user, %User{list_id: list_id})
    |> assign(:list_id, list_id)
  end

  @doc"""
  Changing user (email) to be notified when list_id is complete
  """
  defp apply_action(socket, :edit_user, %{"id" => id} = params) do
    # IO.inspect id
    IO.inspect Lists.get_user!(id)
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Lists.get_user!(id))
  end

  @doc"""
  Listing all todos
  """
  defp apply_action(socket, :index, %{"list_id" => list_id} = params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil) # clear for the form
    |> assign(:todos, list_todos(list_id)) # TODO should this be here??
  end

  @impl true
  def handle_event("delete", %{"id" => id, "listid" => list_id} = params, socket) do
    # the delete event is unable to send parameter "list_id", so I'm sending "listid" (only here)
    todo = Lists.get_todo!(id)
    {:ok, _} = Lists.delete_todo(todo)

    socket = 
      socket
      # |> put_flash(:info, "Todo \"#{todo.text}\" deleted") # does this flash make sense?
      |> assign(:todos, list_todos(list_id))
      # |> check_if_list_complete # not sure this is the best idea either

    # {:noreply, push_redirect(socket, to: "/#{list_id}")}
    {:noreply, socket}
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
    
    socket = check_if_list_complete(socket)

    {:noreply, socket}
  end

  defp check_if_list_complete(socket) do
    IO.puts "Checking if all tasks completed..."
    socket =
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

    socket
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
