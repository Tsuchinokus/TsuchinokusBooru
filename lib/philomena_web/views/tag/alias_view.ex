defmodule TsuchinokusWeb.Tag.AliasView do
  use TsuchinokusWeb, :view

  def alias_target(%{aliased_tag: nil}), do: ""
  def alias_target(%{aliased_tag: tag}), do: tag.name
end
