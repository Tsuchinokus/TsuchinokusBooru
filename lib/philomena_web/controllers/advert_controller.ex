defmodule TsuchinokusWeb.AdvertController do
  use TsuchinokusWeb, :controller

  alias TsuchinokusWeb.AdvertUpdater
  alias Tsuchinokus.Adverts.Advert

  plug :load_resource, model: Advert

  def show(conn, _params) do
    advert = conn.assigns.advert

    AdvertUpdater.cast(:click, advert.id)

    redirect(conn, external: advert.link)
  end
end
