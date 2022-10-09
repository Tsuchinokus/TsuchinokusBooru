defmodule TsuchinokusWeb.Image.SourceChangeController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.SourceChanges.SourceChange
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.CanaryMapPlug, index: :show
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true

  def index(conn, _params) do
    image = conn.assigns.image

    source_changes =
      SourceChange
      |> where(image_id: ^image.id)
      |> preload([:user, image: [:user, tags: :aliases]])
      |> order_by(desc: :id)
      |> Repo.paginate(conn.assigns.scrivener)

    render(conn, "index.html",
      title: "Source Changes on Image #{image.id}",
      image: image,
      source_changes: source_changes
    )
  end
end
