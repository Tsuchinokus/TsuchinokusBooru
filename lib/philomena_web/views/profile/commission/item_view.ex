defmodule TsuchinokusWeb.Profile.Commission.ItemView do
  use TsuchinokusWeb, :view

  alias Tsuchinokus.Commissions.Commission

  def types, do: Commission.types()
end
