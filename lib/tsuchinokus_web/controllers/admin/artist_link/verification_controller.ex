defmodule TsuchinokusWeb.Admin.ArtistLink.VerificationController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.ArtistLinks.ArtistLink
  alias Tsuchinokus.ArtistLinks

  plug TsuchinokusWeb.CanaryMapPlug, create: :edit

  plug :load_and_authorize_resource,
    model: ArtistLink,
    id_name: "artist_link_id",
    persisted: true,
    preload: [:user]

  def create(conn, _params) do
    {:ok, result} =
      ArtistLinks.verify_artist_link(conn.assigns.artist_link, conn.assigns.current_user)

    conn
    |> put_flash(:info, "Artist link successfully verified.")
    |> moderation_log(details: &log_details/3, data: result.artist_link)
    |> redirect(to: Routes.admin_artist_link_path(conn, :index))
  end

  defp log_details(conn, _action, artist_link) do
    %{
      body: "Verified artist link #{artist_link.uri} created by #{artist_link.user.name}",
      subject_path: Routes.profile_artist_link_path(conn, :show, artist_link.user, artist_link)
    }
  end
end
