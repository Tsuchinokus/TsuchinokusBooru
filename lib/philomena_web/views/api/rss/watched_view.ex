defmodule TsuchinokusWeb.Api.Rss.WatchedView do
  use TsuchinokusWeb, :view

  alias TsuchinokusWeb.ImageView

  def last_build_date do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  def medium_url(image) do
    image
    |> ImageView.thumb_urls(false)
    |> Map.get(:medium)
  end
end
