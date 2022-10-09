defmodule TsuchinokusWeb.Api.Json.CommentController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Comments.Comment
  alias Tsuchinokus.Repo
  import Ecto.Query

  def show(conn, %{"id" => id}) do
    comment =
      Comment
      |> where(id: ^id)
      |> preload([:image, :user])
      |> Repo.one()

    cond do
      is_nil(comment) or comment.destroyed_content ->
        conn
        |> put_status(:not_found)
        |> text("")

      comment.image.hidden_from_users ->
        conn
        |> put_status(:forbidden)
        |> text("")

      true ->
        render(conn, "show.json", comment: comment)
    end
  end
end
