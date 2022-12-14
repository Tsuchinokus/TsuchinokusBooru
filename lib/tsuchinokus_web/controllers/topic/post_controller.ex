defmodule TsuchinokusWeb.Topic.PostController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.{Forums.Forum, Topics.Topic, Posts.Post}
  alias Tsuchinokus.Posts
  alias Tsuchinokus.UserStatistics

  plug TsuchinokusWeb.LimitPlug,
       [time: 15, error: "You may only make a post once every 15 seconds."]
       when action in [:create]

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.UserAttributionPlug

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, edit: :show, update: :show

  plug :load_and_authorize_resource,
    model: Forum,
    id_field: "short_name",
    id_name: "forum_id",
    persisted: true

  plug TsuchinokusWeb.LoadTopicPlug
  plug TsuchinokusWeb.CanaryMapPlug, create: :create_post, edit: :create_post, update: :create_post
  plug :authorize_resource, model: Topic, persisted: true

  plug TsuchinokusWeb.LoadPostPlug, [param: "id"] when action in [:edit, :update]
  plug TsuchinokusWeb.CanaryMapPlug, edit: :edit, update: :edit
  plug :authorize_resource, model: Post, only: [:edit, :update]

  def create(conn, %{"post" => post_params}) do
    attributes = conn.assigns.attributes
    forum = conn.assigns.forum
    topic = conn.assigns.topic

    case Posts.create_post(topic, attributes, post_params) do
      {:ok, %{post: post}} ->
        if post.approved do
          Posts.notify_post(post)
          UserStatistics.inc_stat(conn.assigns.current_user, :forum_posts)
        else
          Posts.report_non_approved(post)
        end

        if forum.access_level == "normal" do
          TsuchinokusWeb.Endpoint.broadcast!(
            "firehose",
            "post:create",
            TsuchinokusWeb.Api.Json.Forum.Topic.PostView.render("firehose.json", %{
              post: post,
              topic: topic,
              forum: forum
            })
          )
        end

        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(
          to:
            Routes.forum_topic_path(conn, :show, forum, topic, post_id: post.id) <>
              "#post_#{post.id}"
        )

      _error ->
        conn
        |> put_flash(:error, "There was an error creating the post")
        |> redirect(to: Routes.forum_topic_path(conn, :show, forum, topic))
    end
  end

  def edit(conn, _params) do
    changeset = Posts.change_post(conn.assigns.post)
    render(conn, "edit.html", title: "Editing Post", changeset: changeset)
  end

  def update(conn, %{"post" => post_params}) do
    post = conn.assigns.post
    user = conn.assigns.current_user

    case Posts.update_post(post, user, post_params) do
      {:ok, %{post: post}} ->
        if not post.approved do
          Posts.report_non_approved(post)
        end

        conn
        |> put_flash(:info, "Post successfully edited.")
        |> redirect(
          to:
            Routes.forum_topic_path(conn, :show, post.topic.forum, post.topic, post_id: post.id) <>
              "#post_#{post.id}"
        )

      {:error, :post, changeset, _changes} ->
        render(conn, "edit.html", post: conn.assigns.post, changeset: changeset)
    end
  end
end
