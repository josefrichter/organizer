defmodule OrganizerWeb.Router do
  use OrganizerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OrganizerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: OrganizerWeb.Telemetry
    end
  end

  scope "/", OrganizerWeb do
    pipe_through :browser

    # TODO remove once not needed
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    # live "/", PageLive, :index

    # no slug -> create
    live "/", TodoLive.Index, :index

    live "/:list_id/", TodoLive.Index, :index

    live "/:list_id/add_user", TodoLive.Index, :add_user
    live "/:list_id/edit_user/:id", TodoLive.Index, :edit_user

    live "/:list_id/todos/new", TodoLive.Index, :new
    live "/:list_id/todos/:id/edit", TodoLive.Index, :edit

    live "/:list_id/todos/:id", TodoLive.Show, :show
    live "/:list_id/todos/:id/show/edit", TodoLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", OrganizerWeb do
  #   pipe_through :api
  # end
end
