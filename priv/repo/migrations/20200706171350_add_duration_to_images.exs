defmodule Tsuchinokus.Repo.Migrations.AddDurationToImages do
  use Ecto.Migration

  def change do
    alter table("images") do
      add :image_duration, :float
    end

    # After successful migration:
    #   alias Tsuchinokus.Elasticsearch
    #   alias Tsuchinokus.Images.Image
    #   Elasticsearch.update_mapping!(Image)
  end
end
