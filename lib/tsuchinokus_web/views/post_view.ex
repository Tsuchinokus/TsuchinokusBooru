defmodule TsuchinokusWeb.PostView do
  alias Tsuchinokus.Attribution

  use TsuchinokusWeb, :view

  def markdown_safe_author(object) do
    Tsuchinokus.Markdown.escape("@" <> author_name(object))
  end

  defp author_name(object) do
    cond do
      Attribution.anonymous?(object) || !object.user ->
        TsuchinokusWeb.UserAttributionView.anonymous_name(object)

      true ->
        object.user.name
    end
  end
end
