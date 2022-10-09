defmodule TsuchinokusWeb.Api.Json.Search.ImageController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ImageLoader
  alias Tsuchinokus.Elasticsearch
  alias Tsuchinokus.Interactions
  alias Tsuchinokus.Images.Image
  import Ecto.Query

  def index(conn, params) do
    queryable = Image |> preload([:user, :intensity, tags: :aliases])
    user = conn.assigns.current_user

    case ImageLoader.search_string(conn, params["q"]) do
      {:ok, {images, _tags}} ->
        images = Elasticsearch.search_records(images, queryable)
        interactions = Interactions.user_interactions(images, user)

        conn
        |> put_view(TsuchinokusWeb.Api.Json.ImageView)
        |> render("index.json",
          images: images,
          total: images.total_entries,
          interactions: interactions
        )

      {:error, msg} ->
        conn
        |> Plug.Conn.put_status(:bad_request)
        |> json(%{error: msg})
    end
  end
end
