defmodule TsuchinokusWeb.Tag.ImageView do
  use TsuchinokusWeb, :view

  alias TsuchinokusWeb.TagView

  defp tag_image(tag),
    do: TagView.tag_image(tag)
end
