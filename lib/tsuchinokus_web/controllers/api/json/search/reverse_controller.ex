defmodule TsuchinokusWeb.Api.Json.Search.ReverseController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ImageReverse
  alias Tsuchinokus.Interactions

  plug TsuchinokusWeb.ScraperCachePlug
  plug TsuchinokusWeb.ScraperPlug, params_key: "image", params_name: "image"

  def create(conn, %{"image" => image_params}) do
    user = conn.assigns.current_user

    images =
      image_params
      |> Map.put("distance", conn.params["distance"])
      |> ImageReverse.images()

    interactions = Interactions.user_interactions(images, user)

    conn
    |> put_view(TsuchinokusWeb.Api.Json.ImageView)
    |> render("index.json", images: images, total: length(images), interactions: interactions)
  end
end
