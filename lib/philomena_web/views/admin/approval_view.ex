defmodule TsuchinokusWeb.Admin.ApprovalView do
  use TsuchinokusWeb, :view

  alias TsuchinokusWeb.Admin.ReportView

  # Shamelessly copied from ReportView
  def truncated_ip_link(conn, ip), do: ReportView.truncated_ip_link(conn, ip)

  def image_thumb(conn, image) do
    render(TsuchinokusWeb.ImageView, "_image_container.html",
      image: image,
      size: :thumb_tiny,
      conn: conn
    )
  end
end
