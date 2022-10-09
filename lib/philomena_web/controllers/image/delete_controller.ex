defmodule TsuchinokusWeb.Image.DeleteController do
  use TsuchinokusWeb, :controller

  # N.B.: this would be Image.Hide, because it hides the image, but that is
  # taken by the user action

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide, update: :hide, delete: :hide
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true
  plug :verify_deleted when action in [:update]

  def create(conn, %{"image" => image_params}) do
    image = conn.assigns.image
    user = conn.assigns.current_user

    case Images.hide_image(image, user, image_params) do
      {:ok, result} ->
        conn
        |> put_flash(:info, "Image successfully hidden.")
        |> moderation_log(details: &log_details/3, data: result.image)
        |> redirect(to: Routes.image_path(conn, :show, image))

      _error ->
        conn
        |> put_flash(:error, "Failed to hide image.")
        |> redirect(to: Routes.image_path(conn, :show, image))
    end
  end

  def update(conn, %{"image" => image_params}) do
    image = conn.assigns.image

    case Images.update_hide_reason(image, image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Hide reason updated.")
        |> moderation_log(details: &log_details/3, data: image)
        |> redirect(to: Routes.image_path(conn, :show, image))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Couldn't update hide reason.")
        |> redirect(to: Routes.image_path(conn, :show, image))
    end
  end

  defp verify_deleted(conn, _opts) do
    case conn.assigns.image.hidden_from_users do
      true ->
        conn

      _false ->
        conn
        |> put_flash(:error, "Cannot change hide reason on a non-hidden image!")
        |> redirect(to: Routes.image_path(conn, :show, conn.assigns.image))
        |> halt()
    end
  end

  def delete(conn, _params) do
    image = conn.assigns.image

    {:ok, image} = Images.unhide_image(image)

    conn
    |> put_flash(:info, "Image successfully unhidden.")
    |> moderation_log(details: &log_details/3, data: image)
    |> redirect(to: Routes.image_path(conn, :show, image))
  end

  defp log_details(conn, action, image) do
    body =
      case action do
        :create -> "Hidden image >>#{image.id} (#{image.deletion_reason})"
        :update -> "Changed hide reason of >>#{image.id} (#{image.deletion_reason})"
        :delete -> "Restored image >>#{image.id}"
      end

    %{
      body: body,
      subject_path: Routes.image_path(conn, :show, image)
    }
  end
end
