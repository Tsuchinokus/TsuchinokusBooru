defmodule TsuchinokusWeb.ModerationLogController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.ModerationLogs
  alias Tsuchinokus.ModerationLogs.ModerationLog

  plug :load_and_authorize_resource,
    model: ModerationLog,
    preload: [:user]

  def index(conn, _params) do
    moderation_logs = ModerationLogs.list_moderation_logs(conn)
    render(conn, "index.html", title: "Moderation Logs", moderation_logs: moderation_logs)
  end
end
