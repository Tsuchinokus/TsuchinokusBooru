defmodule TsuchinokusWeb.Image.RepairController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true

  def create(conn, _params) do
    Images.repair_image(conn.assigns.image)
    Images.purge_files(conn.assigns.image, conn.assigns.image.hidden_image_key)

    conn
    |> put_flash(:info, "Repair job enqueued.")
    |> moderation_log(details: &log_details/3, data: conn.assigns.image)
    |> redirect(to: Routes.image_path(conn, :show, conn.assigns.image))
  end

  defp log_details(conn, _action, image) do
    %{
      body: "Repaired image >>#{image.id}",
      subject_path: Routes.image_path(conn, :show, image)
    }
  end
end
