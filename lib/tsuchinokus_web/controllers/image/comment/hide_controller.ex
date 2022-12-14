defmodule TsuchinokusWeb.Image.Comment.HideController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Comments.Comment
  alias Tsuchinokus.Comments

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide, delete: :hide
  plug :load_and_authorize_resource, model: Comment, id_name: "comment_id", persisted: true

  def create(conn, %{"comment" => comment_params}) do
    comment = conn.assigns.comment
    user = conn.assigns.current_user

    case Comments.hide_comment(comment, comment_params, user) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment successfully hidden!")
        |> moderation_log(details: &log_details/3, data: comment)
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )

      _error ->
        conn
        |> put_flash(:error, "Unable to hide comment!")
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )
    end
  end

  def delete(conn, _params) do
    comment = conn.assigns.comment

    case Comments.unhide_comment(comment) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment successfully unhidden!")
        |> moderation_log(details: &log_details/3, data: comment)
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to unhide comment!")
        |> redirect(
          to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
        )
    end
  end

  defp log_details(conn, action, comment) do
    body =
      case action do
        :create -> "Hidden comment on image >>#{comment.image_id} (#{comment.deletion_reason})"
        :delete -> "Restored comment on image >>#{comment.image_id}"
      end

    %{
      body: body,
      subject_path: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
    }
  end
end
