defmodule TsuchinokusWeb.Tag.ReindexController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Tags.Tag
  alias Tsuchinokus.Tags

  plug TsuchinokusWeb.CanaryMapPlug, create: :alias

  plug :load_and_authorize_resource,
    model: Tag,
    id_name: "tag_id",
    id_field: "slug",
    preload: [:implied_tags, :aliased_tag],
    persisted: true

  def create(conn, _params) do
    {:ok, tag} = Tags.reindex_tag_images(conn.assigns.tag)

    conn
    |> put_flash(:info, "Tag reindex started.")
    |> redirect(to: Routes.tag_path(conn, :edit, tag))
  end
end
