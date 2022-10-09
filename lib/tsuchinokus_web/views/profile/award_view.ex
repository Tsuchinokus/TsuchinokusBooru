defmodule TsuchinokusWeb.Profile.AwardView do
  use TsuchinokusWeb, :view

  def badge_options(badges) do
    for badge <- badges do
      [
        key: badge.title,
        value: badge.id,
        data: [set_value: badge.description]
      ]
    end
  end

  def first_badge_label([]) do
    nil
  end

  def first_badge_label([badge | _rest]) do
    badge[:data][:set_value]
  end
end
