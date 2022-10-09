defmodule TsuchinokusWeb.Image.UploaderController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images
  alias Tsuchinokus.Repo

  plug :verify_authorized
  plug :load_resource, model: Image, id_name: "image_id", persisted: true

  def update(conn, %{"image" => image_params}) do
    {:ok, image} = Images.update_uploader(conn.assigns.image, image_params)

    Images.reindex_image(image)

    image = Repo.preload(image, user: [awards: :badge])
    changeset = Images.change_image(image)

    conn
    |> put_view(TsuchinokusWeb.ImageView)
    |> render("_uploader.html", layout: false, image: image, changeset: changeset)
  end

  defp verify_authorized(conn, _opts) do
    case Canada.Can.can?(conn.assigns.current_user, :show, :ip_address) do
      true -> conn
      _false -> TsuchinokusWeb.NotAuthorizedPlug.call(conn)
    end
  end
end
