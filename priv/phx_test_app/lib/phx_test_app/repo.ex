defmodule PhxTestApp.Repo do
  use Ecto.Repo,
    otp_app: :phx_test_app,
    adapter: Ecto.Adapters.Postgres
end
