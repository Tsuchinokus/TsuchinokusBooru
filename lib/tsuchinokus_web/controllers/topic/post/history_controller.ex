defmodule TsuchinokusWeb.Topic.Post.HistoryController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Versions.Version
  alias Tsuchinokus.Versions
  alias Tsuchinokus.Forums.Forum
  alias Tsuchinokus.Repo
  import Ecto.Query

  plug TsuchinokusWeb.CanaryMapPlug, index: :show

  plug :load_and_authorize_resource,
    model: Forum,
    id_name: "forum_id",
    id_field: "short_name",
    persisted: true

  plug TsuchinokusWeb.LoadTopicPlug
  plug TsuchinokusWeb.LoadPostPlug

  def index(conn, _params) do
    topic = conn.assigns.topic
    post = conn.assigns.post

    versions =
      Version
      |> where(item_type: "Post", item_id: ^post.id)
      |> order_by(desc: :created_at)
      |> limit(25)
      |> Repo.all()
      |> Versions.load_data_and_associations(post)

    render(conn, "index.html",
      title: "Post History for Post #{post.id} - #{topic.title} - Forums",
      versions: versions
    )
  end
end
