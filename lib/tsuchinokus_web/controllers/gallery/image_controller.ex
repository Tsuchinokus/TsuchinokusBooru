defmodule TsuchinokusWeb.Gallery.ImageController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Galleries.Gallery
  alias Tsuchinokus.Galleries
  alias Tsuchinokus.Images.Image

  plug TsuchinokusWeb.FilterBannedUsersPlug

  plug TsuchinokusWeb.CanaryMapPlug, create: :edit, delete: :edit
  plug :load_and_authorize_resource, model: Gallery, id_name: "gallery_id", persisted: true

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, delete: :show
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true

  def create(conn, _params) do
    case Galleries.add_image_to_gallery(conn.assigns.gallery, conn.assigns.image) do
      {:ok, _gallery} ->
        json(conn, %{})

      _error ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end

  def delete(conn, _params) do
    case Galleries.remove_image_from_gallery(conn.assigns.gallery, conn.assigns.image) do
      {:ok, _gallery} ->
        json(conn, %{})

      _error ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end
end
