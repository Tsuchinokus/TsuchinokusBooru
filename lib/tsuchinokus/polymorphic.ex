defmodule Tsuchinokus.Polymorphic do
  alias Tsuchinokus.Repo
  import Ecto.Query

  @classes %{
    "Channel" => Tsuchinokus.Channels.Channel,
    "Comment" => Tsuchinokus.Comments.Comment,
    "Commission" => Tsuchinokus.Commissions.Commission,
    "Conversation" => Tsuchinokus.Conversations.Conversation,
    "DnpEntry" => Tsuchinokus.DnpEntries.DnpEntry,
    "Filter" => Tsuchinokus.Filters.Filter,
    "Forum" => Tsuchinokus.Forums.Forum,
    "Gallery" => Tsuchinokus.Galleries.Gallery,
    "Image" => Tsuchinokus.Images.Image,
    "LivestreamChannel" => Tsuchinokus.Channels.Channel,
    "Post" => Tsuchinokus.Posts.Post,
    "Report" => Tsuchinokus.Reports.Report,
    "Topic" => Tsuchinokus.Topics.Topic,
    "User" => Tsuchinokus.Users.User
  }

  @preloads %{
    "Comment" => [:user, image: [tags: :aliases]],
    "Commission" => [:user],
    "Conversation" => [:from, :to],
    "DnpEntry" => [:requesting_user],
    "Gallery" => [:creator],
    "Image" => [:user, tags: :aliases],
    "Post" => [:user, topic: :forum],
    "Topic" => [:forum, :user],
    "Report" => [:user]
  }

  # Deal with Rails polymorphism BS
  def load_polymorphic(structs, associations) when is_list(associations) do
    Enum.reduce(associations, structs, fn asc, acc -> load_polymorphic(acc, asc) end)
  end

  def load_polymorphic(structs, {name, [{id, type}]}) do
    modules_and_ids =
      structs
      |> Enum.group_by(&Map.get(&1, type), &Map.get(&1, id))

    loaded_rows =
      modules_and_ids
      |> Map.new(fn
        {nil, _ids} ->
          {nil, []}

        {type, ids} ->
          pre = Map.get(@preloads, type, [])

          rows =
            @classes[type]
            |> where([m], m.id in ^ids)
            |> preload(^pre)
            |> Repo.all()
            |> Map.new(fn r -> {r.id, r} end)

          {type, rows}
      end)

    structs
    |> Enum.map(fn struct ->
      type = Map.get(struct, type)
      id = Map.get(struct, id)
      row = loaded_rows[type][id]

      %{struct | name => row}
    end)
  end
end
