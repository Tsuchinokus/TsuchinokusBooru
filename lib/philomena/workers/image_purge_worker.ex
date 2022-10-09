defmodule Tsuchinokus.ImagePurgeWorker do
  alias Tsuchinokus.Images

  def perform(files) do
    Images.perform_purge(files)
  end
end
