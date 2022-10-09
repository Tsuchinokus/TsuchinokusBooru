defmodule TsuchinokusWeb.Topic.StickController do
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

  def create(conn, _opts) do
    topic = conn.assigns.topic

    case Topics.stick_topic(topic) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic successfully stickied!")
        |> moderation_log(details: &log_details/3, data: topic)
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to stick the topic!")
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))
    end
  end

  def delete(conn, _opts) do
    topic = conn.assigns.topic

    case Topics.unstick_topic(topic) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic successfully unstickied!")
        |> moderation_log(details: &log_details/3, data: topic)
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to unstick the topic!")
        |> redirect(to: Routes.forum_topic_path(conn, :show, topic.forum, topic))
    end
  end

  defp log_details(conn, action, topic) do
    body =
      case action do
        :create -> "Stickied topic '#{topic.title}' in #{topic.forum.name}"
        :delete -> "Unstickied topic '#{topic.title}' in #{topic.forum.name}"
      end

    %{
      body: body,
      subject_path: Routes.forum_topic_path(conn, :show, topic.forum, topic)
    }
  end
end
