defmodule TsuchinokusWeb.Image.TagController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.TagChanges.TagChange
  alias Tsuchinokus.UserStatistics
  alias Tsuchinokus.Comments
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images
  alias Tsuchinokus.Tags
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.LimitPlug,
       [time: 5, error: "You may only update metadata once every 5 seconds."]
       when action in [:update]

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.CaptchaPlug
  plug TsuchinokusWeb.CheckCaptchaPlug
  plug TsuchinokusWeb.UserAttributionPlug
  plug TsuchinokusWeb.CanaryMapPlug, update: :edit_metadata

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    preload: [:user, :locked_tags, tags: :aliases]

  def update(conn, %{"image" => image_params}) do
    attributes = conn.assigns.attributes
    image = conn.assigns.image

    case Images.update_tags(image, attributes, image_params) do
      {:ok, %{image: {image, added_tags, removed_tags}}} ->
        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "image:tag_update",
          %{
            image_id: image.id,
            added: Enum.map(added_tags, & &1.name),
            removed: Enum.map(removed_tags, & &1.name)
          }
        )

        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "image:update",
          TsuchinokusWeb.Api.Json.ImageView.render("show.json", %{image: image, interactions: []})
        )

        Comments.reindex_comments(image)
        Images.reindex_image(image)
        Tags.reindex_tags(added_tags ++ removed_tags)

        if Enum.any?(added_tags ++ removed_tags) do
          UserStatistics.inc_stat(conn.assigns.current_user, :metadata_updates)
        end

        tag_change_count =
          TagChange
          |> where(image_id: ^image.id)
          |> Repo.aggregate(:count, :id)

        image =
          image
          |> Repo.preload([tags: :aliases], force: true)

        changeset = Images.change_image(image)

        conn
        |> put_view(TsuchinokusWeb.ImageView)
        |> render("_tags.html",
          layout: false,
          tag_change_count: tag_change_count,
          image: image,
          changeset: changeset
        )

      {:error, :image, changeset, _} ->
        image =
          image
          |> Repo.preload([tags: :aliases], force: true)

        conn
        |> put_view(TsuchinokusWeb.ImageView)
        |> render("_tags.html",
          layout: false,
          tag_change_count: 0,
          image: image,
          changeset: changeset
        )
    end
  end
end
