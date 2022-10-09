defmodule Tsuchinokus.Tags.Uploader do
  @moduledoc """
  Upload and processing callback logic for Tag images.
  """

  alias Tsuchinokus.Tags.Tag
  alias Tsuchinokus.Uploader

  def analyze_upload(tag, params) do
    Uploader.analyze_upload(tag, "image", params["image"], &Tag.image_changeset/2)
  end

  def persist_upload(tag) do
    Uploader.persist_upload(tag, tag_file_root(), "image")
  end

  def unpersist_old_upload(tag) do
    Uploader.unpersist_old_upload(tag, tag_file_root(), "image")
  end

  defp tag_file_root do
    Application.get_env(:tsuchinokus, :tag_file_root)
  end
end
