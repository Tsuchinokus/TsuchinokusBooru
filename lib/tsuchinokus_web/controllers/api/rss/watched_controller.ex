defmodule TsuchinokusWeb.Api.Rss.WatchedController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ImageLoader
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Elasticsearch

  import Ecto.Query

  def index(conn, _params) do
    {:ok, {images, _tags}} = ImageLoader.search_string(conn, "my:watched")
    images = Elasticsearch.search_records(images, preload(Image, tags: :aliases))

    # NB: this is RSS, but using the RSS format causes Phoenix not to
    # escape HTML
    render(conn, "index.html", layout: false, images: images)
  end
end
