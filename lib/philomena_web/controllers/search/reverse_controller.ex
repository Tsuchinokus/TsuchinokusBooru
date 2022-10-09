defmodule TsuchinokusWeb.Search.ReverseController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ImageReverse

  plug TsuchinokusWeb.ScraperCachePlug
  plug TsuchinokusWeb.ScraperPlug, params_key: "image", params_name: "image"

  def index(conn, params) do
    create(conn, params)
  end

  def create(conn, %{"image" => image_params})
      when is_map(image_params) and image_params != %{} do
    images = ImageReverse.images(image_params)

    render(conn, "index.html", title: "Reverse Search", images: images)
  end

  def create(conn, _params) do
    render(conn, "index.html", title: "Reverse Search", images: nil)
  end
end
