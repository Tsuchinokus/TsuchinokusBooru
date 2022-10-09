defmodule TsuchinokusWeb.Api.Json.Forum.Topic.PostView do
  use TsuchinokusWeb, :view
  alias TsuchinokusWeb.UserAttributionView

  def render("index.json", %{posts: posts, total: total} = assigns) do
    %{
      posts: render_many(posts, TsuchinokusWeb.Api.Json.Forum.Topic.PostView, "post.json", assigns),
      total: total
    }
  end

  def render("show.json", %{post: post} = assigns) do
    %{post: render_one(post, TsuchinokusWeb.Api.Json.Forum.Topic.PostView, "post.json", assigns)}
  end

  def render("firehose.json", %{post: post, topic: topic, forum: forum} = assigns) do
    %{
      post: render_one(post, TsuchinokusWeb.Api.Json.Forum.Topic.PostView, "post.json", assigns),
      topic: render_one(topic, TsuchinokusWeb.Api.Json.Forum.TopicView, "topic.json", assigns),
      forum: render_one(forum, TsuchinokusWeb.Api.Json.ForumView, "forum.json", assigns)
    }
  end

  def render("post.json", %{post: %{topic: %{hidden_from_users: true}} = post}) do
    %{
      id: post.id,
      user_id: nil,
      author: nil,
      body: nil,
      created_at: nil,
      updated_at: nil,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("post.json", %{post: %{hidden_from_users: true} = post}) do
    %{
      id: post.id,
      user_id: if(not post.anonymous, do: post.user_id),
      author: UserAttributionView.name(post),
      avatar: UserAttributionView.avatar_url(post),
      body: nil,
      created_at: post.created_at,
      updated_at: post.updated_at,
      edited_at: nil,
      edit_reason: nil
    }
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      user_id: if(not post.anonymous, do: post.user_id),
      author: UserAttributionView.name(post),
      avatar: UserAttributionView.avatar_url(post),
      body: post.body,
      created_at: post.created_at,
      updated_at: post.updated_at,
      edited_at: post.edited_at,
      edit_reason: post.edit_reason
    }
  end
end
