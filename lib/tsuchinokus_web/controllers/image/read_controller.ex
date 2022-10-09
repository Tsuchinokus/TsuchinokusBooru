defmodule TsuchinokusWeb.Image.ReadController do
  import Plug.Conn
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images

  plug :load_resource, model: Image, id_name: "image_id", persisted: true

  def create(conn, _params) do
    image = conn.assigns.image
    user = conn.assigns.current_user

    Images.clear_notification(image, user)

    send_resp(conn, :ok, "")
  end
end
