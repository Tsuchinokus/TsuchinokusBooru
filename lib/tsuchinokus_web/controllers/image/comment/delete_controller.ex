defmodule TsuchinokusWeb.Image.Comment.DeleteController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Comments.Comment
  alias Tsuchinokus.Comments

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide
  plug :load_and_authorize_resource, model: Comment, id_name: "comment_id", persisted: true

  def create(conn, _params) do
    comment = conn.assigns.comment

    case Comments.destroy_comment(comment) do
      {:ok, comment} ->
        Comments.reindex_comment(comment)

        conn
        |> put_flash(:info, "Comment successfully destroyed!")
        |> moderation_log(details: &log_details/3, data: comment)
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to destroy comment!")
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )
    end
  end

  defp log_details(conn, _action, comment) do
    %{
      body: "Destroyed comment on image >>#{comment.image_id}",
      subject_path: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
    }
  end
end
