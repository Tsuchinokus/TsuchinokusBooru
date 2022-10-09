defmodule TsuchinokusWeb.DuplicateReport.RejectController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.DuplicateReports.DuplicateReport
  alias Tsuchinokus.DuplicateReports

  plug TsuchinokusWeb.CanaryMapPlug, create: :edit, delete: :edit

  plug :load_and_authorize_resource,
    model: DuplicateReport,
    id_name: "duplicate_report_id",
    persisted: true,
    preload: [:image, :duplicate_of_image]

  def create(conn, _params) do
    {:ok, report} =
      DuplicateReports.reject_duplicate_report(
        conn.assigns.duplicate_report,
        conn.assigns.current_user
      )

    conn
    |> put_flash(:info, "Successfully rejected report.")
    |> moderation_log(details: &log_details/3, data: report)
    |> redirect(to: Routes.duplicate_report_path(conn, :index))
  end

  defp log_details(conn, _action, report) do
    %{
      body: "Rejected duplicate report (#{report.image.id} -> #{report.duplicate_of_image.id})",
      subject_path: Routes.duplicate_report_path(conn, :index)
    }
  end
end
