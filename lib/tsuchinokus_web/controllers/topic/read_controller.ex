defmodule TsuchinokusWeb.Topic.ReadController do
  import Plug.Conn
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Forums.Forum
  alias Tsuchinokus.Topics

  plug :load_resource,
    model: Forum,
    id_name: "forum_id",
    id_field: "short_name",
    persisted: true

  plug TsuchinokusWeb.LoadTopicPlug, show_hidden: true

  def create(conn, _params) do
    user = conn.assigns.current_user

    Topics.clear_notification(conn.assigns.topic, user)

    send_resp(conn, :ok, "")
  end
end
