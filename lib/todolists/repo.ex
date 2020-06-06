defmodule Todolists.Repo do
  use Ecto.Repo,
    otp_app: :todolists,
    adapter: Ecto.Adapters.Postgres
end
