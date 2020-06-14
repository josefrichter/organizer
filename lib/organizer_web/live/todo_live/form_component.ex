defmodule OrganizerWeb.TodoLive.FormComponent do
  use OrganizerWeb, :live_component

  alias Organizer.Lists

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    changeset = Lists.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> Lists.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.action, todo_params)
  end

  # defp save_todo(socket, :edit, todo_params) do
  #   case Lists.update_todo(socket.assigns.todo, todo_params) do
  #     {:ok, _todo} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Todo updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  defp save_todo(socket, :new, todo_params) do
    case Lists.create_todo(todo_params) do
      {:ok, todo} ->
        OrganizerWeb.TodoLive.Index.broadcast(socket.assigns.list_id, todo, :todo_change)
        socket = 
          socket
          # |> put_flash(:info, "Todo created successfully")
          # add just the new todo, but not sure whether it makes sense with phx-update="replace"
          |> assign(:todos, todo) 
          |> push_patch(to: socket.assigns.return_to)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
