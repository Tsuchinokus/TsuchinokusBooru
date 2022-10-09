defmodule TsuchinokusWeb.Image.ReportController do
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

  def new(conn, _params) do
    image = conn.assigns.image
    action = Routes.image_report_path(conn, :create, image)

    changeset =
      %Report{reportable_type: "Image", reportable_id: image.id}
      |> Reports.change_report()

    conn
    |> put_view(ReportView)
    |> render("new.html",
      title: "Reporting Image",
      reportable: image,
      changeset: changeset,
      action: action
    )
  end

  def create(conn, params) do
    image = conn.assigns.image
    action = Routes.image_report_path(conn, :create, image)

    ReportController.create(conn, action, image, "Image", params)
  end
end
