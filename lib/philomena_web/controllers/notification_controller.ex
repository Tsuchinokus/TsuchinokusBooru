defmodule TsuchinokusWeb.NotificationController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Notifications.{UnreadNotification, Notification}
  alias Tsuchinokus.Polymorphic
  alias Tsuchinokus.Repo
  import Ecto.Query

  def index(conn, _params) do
    user = conn.assigns.current_user

    notifications =
      from n in Notification,
        join: un in UnreadNotification,
        on: un.notification_id == n.id,
        where: un.user_id == ^user.id

    notifications =
      notifications
      |> order_by(desc: :updated_at)
      |> Repo.paginate(conn.assigns.scrivener)

    entries =
      notifications.entries
      |> Polymorphic.load_polymorphic(
        actor: [actor_id: :actor_type],
        actor_child: [actor_child_id: :actor_child_type]
      )

    notifications = %{notifications | entries: entries}

    render(conn, "index.html", title: "Notification Area", notifications: notifications)
  end
end
