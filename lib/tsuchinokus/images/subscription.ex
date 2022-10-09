defmodule Tsuchinokus.Images.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Users.User

  @primary_key false

  schema "image_subscriptions" do
    belongs_to :image, Image, primary_key: true
    belongs_to :user, User, primary_key: true
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end
end
