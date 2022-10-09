defmodule TsuchinokusWeb.Image.HashController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images

  plug TsuchinokusWeb.CanaryMapPlug, delete: :hide
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true

  def delete(conn, _params) do
    {:ok, image} = Images.remove_hash(conn.assigns.image)

    conn
    |> put_flash(:info, "Successfully cleared hash.")
    |> moderation_log(details: &log_details/3, data: image)
    |> redirect(to: Routes.image_path(conn, :show, image))
  end

  defp log_details(conn, _action, image) do
    %{
      body: "Cleared hash of image >>#{image.id}",
      subject_path: Routes.image_path(conn, :show, image)
    }
  end
end
