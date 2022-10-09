defmodule TsuchinokusWeb.Api.Json.ImageController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Images
  alias Tsuchinokus.Interactions
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.ScraperCachePlug
  plug TsuchinokusWeb.ApiRequireAuthorizationPlug when action in [:create]
  plug TsuchinokusWeb.UserAttributionPlug when action in [:create]

  plug TsuchinokusWeb.ScraperPlug,
       [params_name: "image", params_key: "image"] when action in [:create]

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    image =
      Image
      |> where(id: ^id)
      |> preload([:user, :intensity, tags: :aliases])
      |> Repo.one()

    case image do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("")

      _ ->
        interactions = Interactions.user_interactions([image], user)

        render(conn, "show.json", image: image, interactions: interactions)
    end
  end

  def create(conn, %{"image" => image_params}) do
    attributes = conn.assigns.attributes

    case Images.create_image(attributes, image_params) do
      {:ok, %{image: image}} ->
        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "image:create",
          TsuchinokusWeb.Api.Json.ImageView.render("show.json", %{image: image, interactions: []})
        )

        render(conn, "show.json", image: image, interactions: [])

      {:error, :image, changeset, _} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end
end
