defmodule TsuchinokusWeb.Filter.ClearRecentController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Users

  plug TsuchinokusWeb.RequireUserPlug

  def delete(conn, _params) do
    {:ok, _user} = Users.clear_recent_filters(conn.assigns.current_user)

    conn
    |> put_flash(:info, "Cleared recent filters.")
    |> redirect(to: Routes.filter_path(conn, :index))
  end
end
