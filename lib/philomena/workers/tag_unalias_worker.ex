defmodule Tsuchinokus.TagUnaliasWorker do
  alias Tsuchinokus.Tags

  def perform(tag_id) do
    Tags.perform_unalias(tag_id)
  end
end
