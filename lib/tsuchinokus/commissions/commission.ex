defmodule Tsuchinokus.Commissions.Commission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tsuchinokus.Commissions.Item
  alias Tsuchinokus.Images.Image
  alias Tsuchinokus.Users.User

  schema "commissions" do
    belongs_to :user, User
    belongs_to :sheet_image, Image
    has_many :items, Item

    field :open, :boolean
    field :categories, {:array, :string}, default: []
    field :information, :string
    field :contact, :string
    field :will_create, :string
    field :will_not_create, :string
    field :commission_items_count, :integer, default: 0

    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  @doc false
  def changeset(commission, attrs) do
    commission
    |> cast(attrs, [
      :information,
      :contact,
      :will_create,
      :will_not_create,
      :open,
      :sheet_image_id,
      :categories
    ])
    |> drop_blank_categories()
    |> validate_required([:user_id, :information, :contact, :open])
    |> validate_length(:information, max: 1000, count: :bytes)
    |> validate_length(:contact, max: 1000, count: :bytes)
    |> validate_length(:will_create, max: 1000, count: :bytes)
    |> validate_length(:will_not_create, max: 1000, count: :bytes)
    |> validate_subset(:categories, Keyword.values(categories()))
  end

  defp drop_blank_categories(changeset) do
    categories =
      changeset
      |> get_field(:categories)
      |> Enum.filter(&(&1 not in [nil, ""]))

    change(changeset, categories: categories)
  end

  def categories do
    [
      Anthro: "Anthro",
      "Official Characters": "Official Characters",
      Comics: "Comics",
      Feral: "Feral",
      "Fetish Art": "Fetish Art",
      Furry: "Furry",
      "Human and humanlike": "Human and humanlike",
      NSFW: "NSFW",
      "Original Characters": "Original Characters",
      "Original Species": "Original Species",
      Requests: "Requests",
      Safe: "Safe",
      Shipping: "Shipping",
      "Violence and Gore": "Violence and Gore"
    ]
  end

  def types do
    [
"Sketch",
      "Colored Sketch",
      "Inked",
      "Flat Color",
      "Vector",
      "Cel Shaded",
      "Fully Shaded",
      "Traditional",
      "Pixel Art",
      "Animation",
      "Crafted Item",
      "Sculpture",
      "Plushie",
      "Other"
      "3D"
      "Shaders"
      "Cell shading"
      "Low poly"
      "High poly"
      "Voxel"
      "VR-Chat"
      "GameDev"
      "Bases"
      "V-Tuber"
      "3D Printing"
      "Props"
      ]
  end
end
