defmodule TsuchinokusWeb.Admin.ApprovalController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug :verify_authorized

  def index(conn, _params) do
    images =
      Image
      |> where(hidden_from_users: false)
      |> where(approved: false)
      |> order_by(asc: :id)
      |> preload([:user, tags: [:aliases, :aliased_tag]])
      |> Repo.paginate(conn.assigns.scrivener)

    render(conn, "index.html", title: "Admin - Approval Queue", images: images)
  end

  defp verify_authorized(conn, _opts) do
    case Canada.Can.can?(conn.assigns.current_user, :approve, %Image{}) do
      true -> conn
      false -> TsuchinokusWeb.NotAuthorizedPlug.call(conn)
    end
  end
end
