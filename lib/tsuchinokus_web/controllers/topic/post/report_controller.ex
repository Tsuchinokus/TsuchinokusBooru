defmodule TsuchinokusWeb.Topic.Post.ReportController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ReportController
  alias TsuchinokusWeb.ReportView
  alias Tsuchinokus.Forums.Forum
  alias Tsuchinokus.Reports.Report
  alias Tsuchinokus.Reports

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.UserAttributionPlug
  plug TsuchinokusWeb.CaptchaPlug
  plug TsuchinokusWeb.CheckCaptchaPlug when action in [:create]

  plug TsuchinokusWeb.CanaryMapPlug, new: :show, create: :show

  plug :load_and_authorize_resource,
    model: Forum,
    id_name: "forum_id",
    id_field: "short_name",
    persisted: true

  plug TsuchinokusWeb.LoadTopicPlug
  plug TsuchinokusWeb.LoadPostPlug

  def new(conn, _params) do
    topic = conn.assigns.topic
    post = conn.assigns.post
    action = Routes.forum_topic_post_report_path(conn, :create, topic.forum, topic, post)

    changeset =
      %Report{reportable_type: "Post", reportable_id: post.id}
      |> Reports.change_report()

    conn
    |> put_view(ReportView)
    |> render("new.html", reportable: post, changeset: changeset, action: action)
  end

  def create(conn, params) do
    topic = conn.assigns.topic
    post = conn.assigns.post
    action = Routes.forum_topic_post_report_path(conn, :create, topic.forum, topic, post)

    ReportController.create(conn, action, post, "Post", params)
  end
end
