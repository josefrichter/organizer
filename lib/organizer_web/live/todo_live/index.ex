defmodule OrganizerWeb.TodoLive.Index do
  use OrganizerWeb, :live_view

  alias Organizer.Lists
  alias Organizer.Lists.Todo

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
    |> assign(:todo, Lists.get_todo!(id))
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
    todo = Lists.get_todo!(id)
    {:ok, _} = Lists.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos(list_id))}
  end

  def handle_event("toggle", %{"id" => id, "list_id" => list_id} = params, socket) do
    todo = Lists.get_todo!(id)
    update_response = 
      Lists.update_todo(todo, %{done: !todo.done})
    case update_response do
      {:ok, _todo} -> 
        socket = assign(socket, :todos, list_todos(list_id))
      {:error, changeset} ->
        socket 
         |> put_flash(:error, "Error: #{changeset.errors}")
    end

        
    IO.puts "Checking if all tasks completed..."
    if list_completed?(list_id) do
      # TODO update variables here
      email = "josef.richter@me.com"
      list_url = "url/#{list_id}"
      IO.puts "All tasks complete!"
      # FIXME the flash message here doesn't work...
      socket 
        |> put_flash(:info, "All tasks complete! Sending notification to #{email}...")
        # |> push_patch(to: "/#{list_id}") # TODO how to redirect from here?
      IO.inspect Task.Supervisor.start_child(Organizer.TaskSupervisor, fn ->
      # Organizer.Mailer.send_completion_notification(email, list_url)
      end)
    else
      IO.puts "Nope, not yet.."
    end  
    

    {:noreply, socket}
  end

  defp list_todos do
    Lists.list_todos()
  end

  defp list_todos(list_id) do
    Lists.list_todos(list_id)
  end

  defp list_completed?(list_id) do
    Lists.list_todos(list_id)
    |> Enum.all?(&(&1.done)) # checks if all true https://hexdocs.pm/elixir/Enum.html#all?/2
  end

end