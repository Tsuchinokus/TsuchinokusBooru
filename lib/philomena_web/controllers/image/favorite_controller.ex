defmodule TsuchinokusWeb.Image.FavoriteController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Repo

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    persisted: true,
    preload: [faves: :user]

  plug :load_votes_if_authorized

  def index(conn, _params) do
    render(conn, "index.html", layout: false)
  end

  defp load_votes_if_authorized(conn, _opts) do
    case Canada.Can.can?(conn.assigns.current_user, :tamper, conn.assigns.image) do
      true ->
        image = Repo.preload(conn.assigns.image, upvotes: :user, downvotes: :user, hides: :user)

        conn
        |> assign(:image, image)
        |> assign(:has_votes, true)

      false ->
        assign(conn, :has_votes, false)
    end
  end
end
