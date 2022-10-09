defimpl Tsuchinokus.Attribution, for: Tsuchinokus.Versions.Version do
  def object_identifier(version) do
    Tsuchinokus.Attribution.object_identifier(version.parent)
  end

  def best_user_identifier(version) do
    Tsuchinokus.Attribution.best_user_identifier(version.parent)
  end

  def anonymous?(version) do
    same_user?(version.user, version.parent) and !!version.parent.anonymous
  end

  defp same_user?(%{id: id}, %{user_id: id}), do: true
  defp same_user?(_user, _parent), do: false
end
