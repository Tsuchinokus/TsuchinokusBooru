defmodule TsuchinokusWeb.SearchView do
  use TsuchinokusWeb, :view

  def scope(conn), do: TsuchinokusWeb.ImageScope.scope(conn)
  def hides_images?(conn), do: can?(conn, :hide, %Tsuchinokus.Images.Image{})
end
