defmodule TsuchinokusWeb.Topic.Post.DeleteController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Posts.Post
  alias Tsuchinokus.Posts

  plug TsuchinokusWeb.CanaryMapPlug, create: :hide

  plug :load_and_authorize_resource,
    model: Post,
    id_name: "post_id",
    persisted: true,
    preload: [:topic, topic: :forum]

  def create(conn, _params) do
    post = conn.assigns.post

    case Posts.destroy_post(post) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post successfully destroyed!")
        |> moderation_log(details: &log_details/3, data: post)
        |> redirect(
          to:
            Routes.forum_topic_path(conn, :show, post.topic.forum, post.topic, post_id: post.id) <>
              "#post_#{post.id}"
        )

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to destroy post!")
        |> redirect(
          to:
            Routes.forum_topic_path(conn, :show, post.topic.forum, post.topic, post_id: post.id) <>
              "#post_#{post.id}"
        )
    end
  end

  defp log_details(conn, _action, post) do
    %{
      body: "Destroyed forum post ##{post.id} in topic '#{post.topic.title}'",
      subject_path:
        Routes.forum_topic_path(conn, :show, post.topic.forum, post.topic, post_id: post.id) <>
          "#post_#{post.id}"
    }
  end
end
