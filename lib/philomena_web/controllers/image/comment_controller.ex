defmodule TsuchinokusWeb.Image.CommentController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.CommentLoader
  alias TsuchinokusWeb.MarkdownRenderer
  alias Tsuchinokus.{Images.Image, Comments.Comment}
  alias Tsuchinokus.UserStatistics
  alias Tsuchinokus.Comments
  alias Tsuchinokus.Images

  plug TsuchinokusWeb.LimitPlug,
       [time: 15, error: "You may only create a comment once every 15 seconds."]
       when action in [:create]

  plug TsuchinokusWeb.FilterBannedUsersPlug when action in [:create, :edit, :update]
  plug TsuchinokusWeb.UserAttributionPlug when action in [:create]

  plug TsuchinokusWeb.CanaryMapPlug,
    create: :create_comment,
    edit: :create_comment,
    update: :create_comment

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    persisted: true,
    preload: [tags: :aliases]

  plug :verify_authorized when action in [:show]
  plug TsuchinokusWeb.FilterForcedUsersPlug when action in [:create, :edit, :update]

  # Undo the previous private parameter screwery
  plug TsuchinokusWeb.LoadCommentPlug, [param: "id", show_hidden: true] when action in [:show]
  plug TsuchinokusWeb.LoadCommentPlug, [param: "id"] when action in [:edit, :update]
  plug TsuchinokusWeb.CanaryMapPlug, create: :create, edit: :edit, update: :edit

  plug :authorize_resource,
    model: Comment,
    only: [:edit, :update],
    preload: [:image, user: [awards: :badge]]

  def index(conn, %{"comment_id" => comment_id}) do
    page = CommentLoader.find_page(conn, conn.assigns.image, comment_id)

    redirect(conn, to: Routes.image_comment_path(conn, :index, conn.assigns.image, page: page))
  end

  def index(conn, _params) do
    comments = CommentLoader.load_comments(conn, conn.assigns.image)

    rendered = MarkdownRenderer.render_collection(comments.entries, conn)

    comments = %{comments | entries: Enum.zip(comments.entries, rendered)}

    render(conn, "index.html", layout: false, image: conn.assigns.image, comments: comments)
  end

  def show(conn, _params) do
    rendered = MarkdownRenderer.render_one(conn.assigns.comment, conn)

    render(conn, "show.html",
      layout: false,
      image: conn.assigns.image,
      comment: conn.assigns.comment,
      body: rendered
    )
  end

  def create(conn, %{"comment" => comment_params}) do
    attributes = conn.assigns.attributes
    image = conn.assigns.image

    case Comments.create_comment(image, attributes, comment_params) do
      {:ok, %{comment: comment}} ->
        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "comment:create",
          TsuchinokusWeb.Api.Json.CommentView.render("show.json", %{comment: comment})
        )

        Comments.reindex_comment(comment)
        Images.reindex_image(conn.assigns.image)

        if comment.approved do
          Comments.notify_comment(comment)
          UserStatistics.inc_stat(conn.assigns.current_user, :comments_posted)
        else
          Comments.report_non_approved(comment)
        end

        index(conn, %{"comment_id" => comment.id})

      _error ->
        conn
        |> put_flash(:error, "There was an error posting your comment")
        |> redirect(to: Routes.image_path(conn, :show, image))
    end
  end

  def edit(conn, _params) do
    changeset =
      conn.assigns.comment
      |> Comments.change_comment()

    render(conn, "edit.html",
      title: "Editing Comment",
      comment: conn.assigns.comment,
      changeset: changeset
    )
  end

  def update(conn, %{"comment" => comment_params}) do
    case Comments.update_comment(conn.assigns.comment, conn.assigns.current_user, comment_params) do
      {:ok, %{comment: comment}} ->
        if not comment.approved do
          Comments.report_non_approved(comment)
        end

        TsuchinokusWeb.Endpoint.broadcast!(
          "firehose",
          "comment:update",
          TsuchinokusWeb.Api.Json.CommentView.render("show.json", %{comment: comment})
        )

        Comments.reindex_comment(comment)

        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(
          to: Routes.image_path(conn, :show, conn.assigns.image) <> "#comment_#{comment.id}"
        )

      {:error, :comment, changeset, _changes} ->
        render(conn, "edit.html", comment: conn.assigns.comment, changeset: changeset)
    end
  end

  defp verify_authorized(conn, _params) do
    image = conn.assigns.image

    image =
      case is_nil(image.duplicate_id) do
        true -> image
        _false -> Images.get_image!(image.duplicate_id)
      end

    conn = assign(conn, :image, image)

    case Canada.Can.can?(conn.assigns.current_user, :show, image) do
      true -> conn
      _false -> TsuchinokusWeb.NotAuthorizedPlug.call(conn)
    end
  end
end
