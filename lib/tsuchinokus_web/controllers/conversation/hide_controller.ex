defmodule TsuchinokusWeb.Conversation.HideController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Conversations.Conversation
  alias Tsuchinokus.Conversations

  plug TsuchinokusWeb.CanaryMapPlug, create: :show, delete: :show

  plug :load_and_authorize_resource,
    model: Conversation,
    id_field: "slug",
    id_name: "conversation_id",
    persisted: true

  def create(conn, _params) do
    conversation = conn.assigns.conversation
    user = conn.assigns.current_user

    {:ok, _conversation} = Conversations.mark_conversation_hidden(conversation, user)

    conn
    |> put_flash(:info, "Conversation hidden.")
    |> redirect(to: Routes.conversation_path(conn, :index))
  end

  def delete(conn, _params) do
    conversation = conn.assigns.conversation
    user = conn.assigns.current_user

    {:ok, _conversation} = Conversations.mark_conversation_hidden(conversation, user, false)

    conn
    |> put_flash(:info, "Conversation restored.")
    |> redirect(to: Routes.conversation_path(conn, :show, conversation))
  end
end
