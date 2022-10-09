defmodule Tsuchinokus.GalleryReorderWorker do
  alias Tsuchinokus.Galleries

  def perform(gallery_id, image_ids) do
    Galleries.perform_reorder(gallery_id, image_ids)
  end
end
