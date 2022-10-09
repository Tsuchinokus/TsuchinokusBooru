defmodule TsuchinokusWeb.Image.ScrapeController do
  use TsuchinokusWeb, :controller

  alias Tsuchinokus.Scrapers

  def create(conn, params) do
    result =
      params
      |> Map.get("url")
      |> to_string()
      |> String.trim()
      |> Scrapers.scrape!()

    conn
    |> json(result)
  end
end
