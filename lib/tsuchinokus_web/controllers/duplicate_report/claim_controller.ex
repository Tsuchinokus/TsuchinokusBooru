defmodule TsuchinokusWeb.DuplicateReport.ClaimController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.DuplicateReports.DuplicateReport
  alias Tsuchinokus.DuplicateReports

  plug TsuchinokusWeb.CanaryMapPlug, create: :edit, delete: :edit

  plug :load_and_authorize_resource,
    model: DuplicateReport,
    id_name: "duplicate_report_id",
    persisted: true

  def create(conn, _params) do
    {:ok, report} =
      DuplicateReports.claim_duplicate_report(
        conn.assigns.duplicate_report,
        conn.assigns.current_user
      )

    conn
    |> put_flash(:info, "Successfully claimed report.")
    |> moderation_log(details: &log_details/3, data: report)
    |> redirect(to: Routes.duplicate_report_path(conn, :index))
  end

  def delete(conn, _params) do
    {:ok, _report} = DuplicateReports.unclaim_duplicate_report(conn.assigns.duplicate_report)

    conn
    |> put_flash(:info, "Successfully released report.")
    |> moderation_log(details: &log_details/3)
    |> redirect(to: Routes.duplicate_report_path(conn, :index))
  end

  defp log_details(conn, action, _) do
    body =
      case action do
        :create -> "Claimed a duplicate report"
        :delete -> "Released a duplicate report"
      end

    %{
      body: body,
      subject_path: Routes.duplicate_report_path(conn, :index)
    }
  end
end
