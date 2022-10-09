defmodule TsuchinokusWeb.Image.SourceController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.SourceChanges.SourceChange
  alias Tsuchinokus.UserStatistics
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images
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
    preload: [:user, tags: :aliases]

  def update(conn, %{"image" => image_params}) do
    attributes = conn.assigns.attributes
    image = conn.assigns.image
    old_source = image.source_url

    case Images.update_source(image, attributes, image_params) do
      {:ok, %{image: image}} ->
        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "image:source_update",
          %{image_id: image.id, added: [image.source_url], removed: [old_source]}
        )

        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "image:update",
          TsuchinokusWeb.Api.Json.ImageView.render("show.json", %{image: image, interactions: []})
        )

        changeset = Images.change_image(image)

        source_change_count =
          SourceChange
          |> where(image_id: ^image.id)
          |> Repo.aggregate(:count, :id)

        if old_source != image.source_url do
          UserStatistics.inc_stat(conn.assigns.current_user, :metadata_updates)
        end

        Images.reindex_image(image)

        conn
        |> put_view(TsuchinokusWeb.ImageView)
        |> render("_source.html",
          layout: false,
          source_change_count: source_change_count,
          image: image,
          changeset: changeset
        )

      {:error, :image, changeset, _} ->
        conn
        |> put_view(TsuchinokusWeb.ImageView)
        |> render("_source.html",
          layout: false,
          source_change_count: 0,
          image: image,
          changeset: changeset
        )
    end
  end
end
