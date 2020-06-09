defmodule Organizer.Repo do
  use Ecto.Repo,
    otp_app: :organizer,
    adapter: Ecto.Adapters.Postgres
end
