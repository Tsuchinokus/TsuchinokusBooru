defmodule TsuchinokusWeb.Profile.SourceChangeController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Users.User
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.SourceChanges.SourceChange
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.CanaryMapPlug, index: :show

  plug :load_and_authorize_resource,
    model: User,
    id_name: "profile_id",
    id_field: "slug",
    persisted: true

  def index(conn, _params) do
    user = conn.assigns.user

    source_changes =
      SourceChange
      |> join(:inner, [sc], i in Image, on: sc.image_id == i.id)
      |> where(
        [sc, i],
        sc.user_id == ^user.id and not (i.user_id == ^user.id and i.anonymous == true)
      )
      |> preload([:user, image: [:user, tags: :aliases]])
      |> order_by(desc: :id)
      |> Repo.paginate(conn.assigns.scrivener)

    render(conn, "index.html",
      title: "Source Changes for User `#{user.name}'",
      user: user,
      source_changes: source_changes
    )
  end
end
