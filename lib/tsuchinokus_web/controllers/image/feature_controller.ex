defmodule TsuchinokusWeb.Image.FeatureController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true
  plug :verify_not_deleted

  def create(conn, _params) do
    user = conn.assigns.current_user
    image = conn.assigns.image

    {:ok, _feature} = Images.feature_image(user, image)

    conn
    |> put_flash(:info, "Image marked as featured image.")
    |> moderation_log(details: &log_details/3, data: image)
    |> redirect(to: Routes.image_path(conn, :show, image))
  end

  defp verify_not_deleted(conn, _opts) do
    case conn.assigns.image.hidden_from_users do
      true ->
        conn
        |> put_flash(:error, "Cannot feature a hidden image.")
        |> redirect(to: Routes.image_path(conn, :show, conn.assigns.image))
        |> halt()

      _false ->
        conn
    end
  end

  defp log_details(conn, _action, image) do
    %{
      body: "Featured image >>#{image.id}",
      subject_path: Routes.image_path(conn, :show, image)
    }
  end
end
