defmodule OrganizerWeb.TodoLive.Index do
  use OrganizerWeb, :live_view

  alias Organizer.Lists
  alias Organizer.Lists.Todo
  alias Organizer.Lists.User

  @impl true
  @doc """
  Mount function for "/any-new-slug"
  Will assign all todos for given slug
  Will assign user email for given slug, if any
  """
  def mount(%{"list_id" => list_id}, _session, socket) do
    if connected?(socket), do: subscribe(list_id)

    socket =
      socket
      # |> assign(:todos, list_todos(list_id))
      |> assign(:user, get_user(list_id))
      |> assign(:list_id, list_id)

    {:ok, socket}
  end

  # TODO move this mount into router redirect?
  @doc """
  When "/" is reached, a new random slug is generated
  followed by redirect to "/the-new-slug"
  TODO shouldn't this happen already in router?
  """
  def mount(%{}, _session, socket) do
    new_list_id = MnemonicSlugs.generate_slug(3)
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

  @doc """
  Prepare socket for creating new Todo
  """
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    # create empty Todo, pre-filled with list_id (hidden field in form)
    |> assign(:todo, %Todo{list_id: socket.assigns.list_id})
  end

  @doc """
  Adding user (email) to be notified when list_id is complete
  """
  defp apply_action(socket, :add_user, _params) do
    socket
    |> assign(:page_title, "Add User")
    |> assign(:user, %User{list_id: socket.assigns.list_id})
    |> assign(:list_id, socket.assigns.list_id)
  end

  @doc """
  Changing user (email) to be notified when list_id is complete
  """
  defp apply_action(socket, :edit_user, %{"id" => id} = params) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Lists.get_user!(id))
  end

  @doc """
  Listing all todos
  """
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
    # need this here rather than in mount, because of push_patch
    |> assign(:todos, list_todos(socket.assigns.list_id))
  end

  @impl true
  def handle_event("delete", %{"id" => id} = params, socket) do
    todo = Lists.get_todo!(id)
    {:ok, _} = Lists.delete_todo(todo)
    broadcast(socket.assigns.list_id, nil, :todo_change)

    socket =
      socket
      # |> put_flash(:info, "Todo \"#{todo.text}\" deleted") # does this flash make sense?
      |> assign(:todos, list_todos(socket.assigns.list_id))

    # |> check_if_list_complete # not sure this is the best idea either

    # {:noreply, push_redirect(socket, to: "/#{list_id}")}
    {:noreply, socket}
  end

  def handle_event("toggle", %{"id" => id} = params, socket) do
    todo = Lists.get_todo!(id)
    update_response = Lists.update_todo(todo, %{done: !todo.done})

    socket =
      case update_response do
        {:ok, todo} ->
          broadcast(socket.assigns.list_id, todo, :todo_change)
          socket = assign(socket, :todos, list_todos(socket.assigns.list_id))

        {:error, changeset} ->
          socket
          |> put_flash(:error, "Error: #{changeset.errors}")
      end

    socket = check_if_list_complete(socket)

    {:noreply, socket}
  end

  defp check_if_list_complete(socket) do
    IO.puts("Checking if all tasks completed...")

    socket =
      if socket.assigns.user && list_completed?(socket.assigns.list_id) do
        email = socket.assigns.user.email
        list_id = socket.assigns.list_id

        send_completion_notification(email, list_id)

        IO.puts("All tasks complete!")

        put_flash(socket, :info, "All tasks complete! Sending notification to #{email}...")
      else
        IO.puts("Nope, either no user, or list not complete yet...")

        socket
      end

    socket
  end

  defp send_completion_notification(email, list_id) do
    Task.Supervisor.start_child(Organizer.TaskSupervisor, fn ->
      IO.puts("Sending to #{email} from within a Task")
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
    # checks if all true https://hexdocs.pm/elixir/Enum.html#all?/2
    |> Enum.all?(& &1.done)
  end

  def subscribe(list_id) do
    Phoenix.PubSub.subscribe(Organizer.PubSub, "todos-#{list_id}")
  end

  def broadcast(list_id, todo, event) do
    Phoenix.PubSub.broadcast(Organizer.PubSub, "todos-#{list_id}", {todo, event})
    todo
  end

  def handle_info({todo, :todo_change}, socket) do
    {:noreply, assign(socket, :todos, list_todos(socket.assigns.list_id))}
  end
end
