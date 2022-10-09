defmodule TsuchinokusWeb.Api.Json.OembedView do
  use TsuchinokusWeb, :view

  def render("error.json", _assigns) do
    %{
      error: "Couldn't find an image"
    }
  end

  def render("show.json", %{image: image}) do
    %{
      version: "1.0",
      type: "photo",
      title: "##{image.id} - #{tag_list(image)} - Tsuchinokus",
      author_url: image.source_url || "",
      author_name: artist_tags(image.tags),
      provider_name: "Tsuchinokus",
      provider_url: TsuchinokusWeb.Endpoint.url(),
      cache_age: 7200,
      tsuchinokus_id: image.id,
      tsuchinokus_score: image.score,
      tsuchinokus_comments: image.comments_count,
      tsuchinokus_tags: Enum.map(image.tags, & &1.name)
    }
  end

  defp artist_tags(tags) do
    tags
    |> Enum.filter(&(&1.namespace == "artist"))
    |> Enum.map_join(", ", & &1.name_in_namespace)
  end
end
