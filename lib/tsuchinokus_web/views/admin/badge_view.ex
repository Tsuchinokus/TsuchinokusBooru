defmodule TsuchinokusWeb.Admin.BadgeView do
  use TsuchinokusWeb, :view

  alias TsuchinokusWeb.ProfileView

  defp badge_image(badge, options),
    do: ProfileView.badge_image(badge, options)
end
