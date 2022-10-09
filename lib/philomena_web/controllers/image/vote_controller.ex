defmodule TsuchinokusWeb.Image.VoteController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.{Images, Images.Image}
  alias Tsuchinokus.ImageVotes
  alias Tsuchinokus.Repo
  alias Ecto.Multi

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.CanaryMapPlug, create: :vote, delete: :vote

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    persisted: true,
    preload: [tags: :aliases]

  plug TsuchinokusWeb.FilterForcedUsersPlug

  def create(conn, params) do
    user = conn.assigns.current_user
    image = conn.assigns.image

    Multi.append(
      ImageVotes.delete_vote_transaction(image, user),
      ImageVotes.create_vote_transaction(image, user, params["up"] == true)
    )
    |> Repo.transaction()
    |> case do
      {:ok, _result} ->
        image =
          Images.get_image!(image.id)
          |> Images.reindex_image()

        conn
        |> json(Image.interaction_data(image))

      _error ->
        conn
        |> Plug.Conn.put_status(409)
        |> json(%{})
    end
  end

  def delete(conn, _params) do
    user = conn.assigns.current_user
    image = conn.assigns.image

    ImageVotes.delete_vote_transaction(image, user)
    |> Repo.transaction()
    |> case do
      {:ok, _result} ->
        image =
          Images.get_image!(image.id)
          |> Images.reindex_image()

        conn
        |> json(Image.interaction_data(image))

      _error ->
        conn
        |> Plug.Conn.put_status(409)
        |> json(%{})
    end
  end
end
