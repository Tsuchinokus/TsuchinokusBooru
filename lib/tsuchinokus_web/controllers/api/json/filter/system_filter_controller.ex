defmodule TsuchinokusWeb.Api.Json.Filter.SystemFilterController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Filters.Filter
  alias Tsuchinokus.Repo
  import Ecto.Query

  def index(conn, _params) do
    system_filters =
      Filter
      |> where(system: true)
      |> order_by(asc: :id)
      |> Repo.paginate(conn.assigns.scrivener)

    conn
    |> put_view(TsuchinokusWeb.Api.Json.FilterView)
    |> render("index.json", filters: system_filters, total: system_filters.total_entries)
  end
end
