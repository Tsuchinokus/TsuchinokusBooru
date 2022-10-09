defmodule TsuchinokusWeb.CommissionView do
  use TsuchinokusWeb, :view

  alias Tsuchinokus.Commissions.Commission

  def categories, do: [[key: "-", value: ""] | Commission.categories()]
  def types, do: Commission.types()
end
