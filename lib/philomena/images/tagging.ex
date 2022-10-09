defmodule Tsuchinokus.Images.Tagging do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Tags.Tag

  @primary_key false

  schema "image_taggings" do
    belongs_to :image, Image, primary_key: true
    belongs_to :tag, Tag, primary_key: true
  end

  @doc false
  def changeset(tagging, attrs) do
    tagging
    |> cast(attrs, [])
    |> validate_required([])
  end
end
