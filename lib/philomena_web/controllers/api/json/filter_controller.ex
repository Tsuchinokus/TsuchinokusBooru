defmodule TsuchinokusWeb.Api.Json.FilterController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Filters.Filter
  alias Tsuchinokus.Repo
  import Ecto.Query

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    filter =
      Filter
      |> where(id: ^id)
      |> preload(:user)
      |> Repo.one()

    case Canada.Can.can?(user, :show, filter) do
      true ->
        render(conn, "show.json", filter: filter)

      _ ->
        conn
        |> put_status(:not_found)
        |> text("")
    end
  end
end
