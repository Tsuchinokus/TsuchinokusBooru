defmodule TsuchinokusWeb.Session.TotpController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.LayoutView
  alias TsuchinokusWeb.UserAuth
  alias Tsuchinokus.Users.User
  alias Tsuchinokus.Users
  alias Tsuchinokus.Repo

  def new(conn, _params) do
    changeset = Users.change_user(conn.assigns.current_user)

    render(conn, "new.html", layout: {LayoutView, "two_factor.html"}, changeset: changeset)
  end

  def create(conn, params) do
    %{"user" => user_params} = params

    conn.assigns.current_user
    |> User.consume_totp_token_changeset(params)
    |> Repo.update()
    |> case do
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Invalid TOTP token entered. Please sign in again.")
        |> UserAuth.log_out_user()

      {:ok, user} ->
        UserAuth.totp_auth_user(conn, user, user_params)
    end
  end
end
