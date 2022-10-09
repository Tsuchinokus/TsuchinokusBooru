defmodule Tsuchinokus.TagDeleteWorker do
  alias Tsuchinokus.Tags

  def perform(tag_id) do
    Tags.perform_delete(tag_id)
  end
end
