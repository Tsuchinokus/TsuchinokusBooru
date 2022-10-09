defmodule TsuchinokusWeb.Admin.User.ActivationController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Users.User
  alias Tsuchinokus.Users

  plug :verify_authorized
  plug :load_resource, model: User, id_name: "user_id", id_field: "slug", persisted: true

  def create(conn, _params) do
    {:ok, user} = Users.reactivate_user(conn.assigns.user)

    conn
    |> put_flash(:info, "User was reactivated.")
    |> redirect(to: Routes.profile_path(conn, :show, user))
  end

  def delete(conn, _params) do
    {:ok, user} = Users.deactivate_user(conn.assigns.current_user, conn.assigns.user)

    conn
    |> put_flash(:info, "User was deactivated.")
    |> redirect(to: Routes.profile_path(conn, :show, user))
  end

  defp verify_authorized(conn, _opts) do
    case Canada.Can.can?(conn.assigns.current_user, :index, User) do
      true -> conn
      _false -> TsuchinokusWeb.NotAuthorizedPlug.call(conn)
    end
  end
end
