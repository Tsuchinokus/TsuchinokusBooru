defmodule TsuchinokusWeb.Image.Comment.ApproveController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Comments.Comment
  alias Tsuchinokus.Comments
  alias Tsuchinokus.UserStatistics

  plug TsuchinokusWeb.CanaryMapPlug, create: :approve

  plug :load_and_authorize_resource,
    model: Comment,
    id_name: "comment_id",
    persisted: true,
    preload: [:user]

  def create(conn, _params) do
    comment = conn.assigns.comment

    {:ok, _comment} = Comments.approve_comment(comment, conn.assigns.current_user)

    UserStatistics.inc_stat(comment.user, :comments_posted)

    conn
    |> put_flash(:info, "Comment has been approved.")
    |> moderation_log(details: &log_details/3, data: comment)
    |> redirect(to: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}")
  end

  defp log_details(conn, _action, comment) do
    %{
      body: "Approved comment on image >>#{comment.image_id}",
      subject_path: Routes.image_path(conn, :show, comment.image_id) <> "#comment_#{comment.id}"
    }
  end
end
