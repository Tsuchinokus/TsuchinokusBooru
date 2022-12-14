defmodule TsuchinokusWeb.Topic.LockController do
  import Plug.Conn
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Forums.Forum
  alias Tsuchinokus.Topics.Topic
  alias Tsuchinokus.Topics

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, delete: :show

  plug :load_and_authorize_resource,
    model: Forum,
    id_name: "forum_id",
    id_field: "short_name",
    persisted: true

  plug TsuchinokusWeb.LoadTopicPlug
  plug TsuchinokusWeb.CanaryMapPlug, create: :hide, delete: :hide
  plug :authorize_resource, model: Topic, persisted: true

  def create(conn, %{"topic" => topic_params}) do
    topic = conn.assigns.topic
    user = conn.assigns.current_user

    case Topics.lock_topic(topic, topic_params, user) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic successfully locked!")
        |> moderation_log(details: &log_details/3, data: topic)
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to lock the topic!")
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))
    end
  end

  def delete(conn, _opts) do
    topic = conn.assigns.topic

    case Topics.unlock_topic(topic) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic successfully unlocked!")
        |> moderation_log(details: &log_details/3, data: topic)
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to unlock the topic!")
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))
    end
  end

  defp log_details(conn, action, topic) do
    body =
      case action do
        :create -> "Locked topic '#{topic.title}' (#{topic.lock_reason}) in #{topic.forum.name}"
        :delete -> "Unlocked topic '#{topic.title}' in #{topic.forum.name}"
      end

    %{
      body: body,
      subject_path: Routes.forum_topic_path(conn, :show, topic.forum, topic)
    }
  end
end
