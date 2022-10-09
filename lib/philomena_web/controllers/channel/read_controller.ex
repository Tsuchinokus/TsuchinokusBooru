defmodule TsuchinokusWeb.Channel.ReadController do
  import Plug.Conn
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Channels.Channel
  alias Tsuchinokus.Channels

  plug :load_resource, model: Channel, id_name: "channel_id", persisted: true

  def create(conn, _params) do
    channel = conn.assigns.channel
    user = conn.assigns.current_user

    Channels.clear_notification(channel, user)

    send_resp(conn, :ok, "")
  end
end
