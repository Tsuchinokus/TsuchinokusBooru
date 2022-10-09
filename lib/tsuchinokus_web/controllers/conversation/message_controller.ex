defmodule TsuchinokusWeb.Conversation.MessageController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Conversations.{Conversation, Message}
  alias Tsuchinokus.Conversations
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.FilterBannedUsersPlug
  plug TsuchinokusWeb.CanaryMapPlug, create: :show

  plug :load_and_authorize_resource,
    model: Conversation,
    id_name: "conversation_id",
    id_field: "slug",
    persisted: true

  def create(conn, %{"message" => message_params}) do
    conversation = conn.assigns.conversation
    user = conn.assigns.current_user

    case Conversations.create_message(conversation, user, message_params) do
      {:ok, %{message: message}} ->
        if not message.approved do
          Conversations.report_non_approved(message.conversation_id)
        end

        count =
          Message
          |> where(conversation_id: ^conversation.id)
          |> Repo.aggregate(:count, :id)

        page =
          Float.ceil(count / 25)
          |> round()

        conn
        |> put_flash(:info, "Message successfully sent.")
        |> redirect(to: Routes.conversation_path(conn, :show, conversation, page: page))

      _error ->
        conn
        |> put_flash(:error, "There was an error posting your message")
        |> redirect(to: Routes.conversation_path(conn, :show, conversation))
    end
  end
end
