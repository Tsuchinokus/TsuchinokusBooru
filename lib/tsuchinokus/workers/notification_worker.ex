defmodule Tsuchinokus.NotificationWorker do
  @modules %{
    "Comments" => Tsuchinokus.Comments,
    "Galleries" => Tsuchinokus.Galleries,
    "Images" => Tsuchinokus.Images,
    "Posts" => Tsuchinokus.Posts,
    "Topics" => Tsuchinokus.Topics
  }

  def perform(module, args) do
    @modules[module].perform_notify(args)
  end
end
