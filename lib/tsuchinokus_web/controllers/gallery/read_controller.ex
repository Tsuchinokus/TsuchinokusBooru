defmodule TsuchinokusWeb.Gallery.ReadController do
  import Plug.Conn
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Galleries.Gallery
  alias Tsuchinokus.Galleries

  plug :load_resource, model: Gallery, id_name: "gallery_id", persisted: true

  def create(conn, _params) do
    gallery = conn.assigns.gallery
    user = conn.assigns.current_user

    Galleries.clear_notification(gallery, user)

    send_resp(conn, :ok, "")
  end
end
