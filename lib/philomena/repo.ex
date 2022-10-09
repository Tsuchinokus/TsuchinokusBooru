defmodule Tsuchinokus.Repo do
  use Ecto.Repo,
    otp_app: :tsuchinokus,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 250
end
