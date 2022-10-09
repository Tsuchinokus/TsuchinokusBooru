defmodule TsuchinokusWeb.Profile.ReportController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ReportController
  alias TsuchinokusWeb.ReportView
  alias Tsuchinokus.Users.User
  alias Tsuchinokus.Reports.Report
  alias Tsuchinokus.Reports

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.UserAttributionPlug
  plug TsuchinokusWeb.CaptchaPlug
  plug TsuchinokusWeb.CheckCaptchaPlug when action in [:create]
  plug TsuchinokusWeb.CanaryMapPlug, new: :show, create: :show

  plug :load_and_authorize_resource,
    model: User,
    id_name: "profile_id",
    id_field: "slug",
    persisted: true

  def new(conn, _params) do
    user = conn.assigns.user
    action = Routes.profile_report_path(conn, :create, user)

    changeset =
      %Report{reportable_type: "User", reportable_id: user.id}
      |> Reports.change_report()

    conn
    |> put_view(ReportView)
    |> render("new.html",
      title: "Reporting User",
      reportable: user,
      changeset: changeset,
      action: action
    )
  end

  def create(conn, params) do
    user = conn.assigns.user
    action = Routes.profile_report_path(conn, :create, user)

    ReportController.create(conn, action, user, "User", params)
  end
end
