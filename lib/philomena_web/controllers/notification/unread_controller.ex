defmodule TsuchinokusWeb.Notification.UnreadController do
  use TsuchinokusWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      notifications: conn.assigns.notification_count,
      conversations: conn.assigns.conversation_count
    })
  end
end
