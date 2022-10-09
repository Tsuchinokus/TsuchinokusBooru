defmodule Tsuchinokus.ThumbnailWorker do
  alias Tsuchinokus.Images.Thumbnailer
  alias Tsuchinokus.Images

  def perform(image_id) do
    Thumbnailer.generate_thumbnails(image_id)

    TsuchinokusWeb.Endpoint.broadcast!(
      "firehose",
      "image:process",
      %{image_id: image_id}
    )

    image_id
    |> Images.get_image!()
    |> Images.reindex_image()
  end
end
