defmodule TsuchinokusWeb.Image.Comment.ReportController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ReportController
  alias TsuchinokusWeb.ReportView
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Reports.Report
  alias Tsuchinokus.Reports

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.UserAttributionPlug
  plug TsuchinokusWeb.CaptchaPlug
  plug TsuchinokusWeb.CheckCaptchaPlug when action in [:create]

  plug TsuchinokusWeb.CanaryMapPlug, new: :show, create: :show

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    persisted: true,
    preload: [tags: :aliases]

  plug TsuchinokusWeb.LoadCommentPlug

  def new(conn, _params) do
    comment = conn.assigns.comment
    action = Routes.image_comment_report_path(conn, :create, comment.image, comment)

    changeset =
      %Report{reportable_type: "Comment", reportable_id: comment.id}
      |> Reports.change_report()

    conn
    |> put_view(ReportView)
    |> render("new.html",
      title: "Reporting Comment",
      reportable: comment,
      changeset: changeset,
      action: action
    )
  end

  def create(conn, params) do
    comment = conn.assigns.comment
    action = Routes.image_comment_report_path(conn, :create, comment.image, comment)

    ReportController.create(conn, action, comment, "Comment", params)
  end
end
