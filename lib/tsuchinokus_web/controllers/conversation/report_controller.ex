defmodule TsuchinokusWeb.Conversation.ReportController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.ReportController
  alias TsuchinokusWeb.ReportView
  alias Tsuchinokus.Conversations.Conversation
  alias Tsuchinokus.Reports.Report
  alias Tsuchinokus.Reports

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.UserAttributionPlug
  plug TsuchinokusWeb.CaptchaPlug
  plug TsuchinokusWeb.CheckCaptchaPlug when action in [:create]
  plug TsuchinokusWeb.CanaryMapPlug, new: :show, create: :show

  plug :load_and_authorize_resource,
    model: Conversation,
    id_name: "conversation_id",
    id_field: "slug",
    persisted: true,
    preload: [:from, :to]

  def new(conn, _params) do
    conversation = conn.assigns.conversation
    action = Routes.conversation_report_path(conn, :create, conversation)

    changeset =
      %Report{reportable_type: "Conversation", reportable_id: conversation.id}
      |> Reports.change_report()

    conn
    |> put_view(ReportView)
    |> render("new.html",
      title: "Reporting Conversation",
      reportable: conversation,
      changeset: changeset,
      action: action
    )
  end

  def create(conn, params) do
    conversation = conn.assigns.conversation
    action = Routes.conversation_report_path(conn, :create, conversation)

    ReportController.create(conn, action, conversation, "Conversation", params)
  end
end
