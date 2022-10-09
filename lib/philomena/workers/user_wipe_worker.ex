defmodule Tsuchinokus.UserWipeWorker do
  alias Tsuchinokus.UserWipe

  def perform(user_id) do
    UserWipe.perform(user_id)
  end
end
