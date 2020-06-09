defmodule Organizer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Organizer.Repo,
      # Start the Telemetry supervisor
      OrganizerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Organizer.PubSub},
      # Start the Endpoint (http/https)
      OrganizerWeb.Endpoint,
      # Start a worker by calling: Organizer.Worker.start_link(arg)
      # {Organizer.Worker, arg}
      {Task.Supervisor, name: Organizer.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Organizer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OrganizerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
