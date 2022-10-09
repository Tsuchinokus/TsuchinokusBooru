defmodule TsuchinokusWeb.Channel.SubscriptionController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Channels.Channel
  alias Tsuchinokus.Channels

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, delete: :show
  plug :load_and_authorize_resource, model: Channel, id_name: "channel_id", persisted: true

  def create(conn, _params) do
    channel = conn.assigns.channel
    user = conn.assigns.current_user

    case Channels.create_subscription(channel, user) do
      {:ok, _subscription} ->
        render(conn, "_subscription.html", channel: channel, watching: true, layout: false)

      {:error, _changeset} ->
        render(conn, "_error.html", layout: false)
    end
  end

  def delete(conn, _params) do
    channel = conn.assigns.channel
    user = conn.assigns.current_user

    case Channels.delete_subscription(channel, user) do
      {:ok, _subscription} ->
        render(conn, "_subscription.html", channel: channel, watching: false, layout: false)

      {:error, _changeset} ->
        render(conn, "_error.html", layout: false)
    end
  end
end
