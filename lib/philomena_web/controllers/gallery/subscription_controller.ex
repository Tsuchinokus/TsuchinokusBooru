defmodule TsuchinokusWeb.Gallery.SubscriptionController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Galleries.Gallery
  alias Tsuchinokus.Galleries

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, delete: :show
  plug :load_and_authorize_resource, model: Gallery, id_name: "gallery_id", persisted: true

  def create(conn, _params) do
    gallery = conn.assigns.gallery
    user = conn.assigns.current_user

    case Galleries.create_subscription(gallery, user) do
      {:ok, _subscription} ->
        render(conn, "_subscription.html", gallery: gallery, watching: true, layout: false)

      {:error, _changeset} ->
        render(conn, "_error.html", layout: false)
    end
  end

  def delete(conn, _params) do
    gallery = conn.assigns.gallery
    user = conn.assigns.current_user

    case Galleries.delete_subscription(gallery, user) do
      {:ok, _subscription} ->
        render(conn, "_subscription.html", gallery: gallery, watching: false, layout: false)

      {:error, _changeset} ->
        render(conn, "_error.html", layout: false)
    end
  end
end
