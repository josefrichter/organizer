defmodule TodolistsWeb.TodoLive.Show do
  use TodolistsWeb, :live_view

  alias Todolists.TodoLists

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:todo, TodoLists.get_todo!(id))}
  end

  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit Todo"
end
