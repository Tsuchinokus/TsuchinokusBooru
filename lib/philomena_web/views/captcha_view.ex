defmodule TsuchinokusWeb.CaptchaView do
  use TsuchinokusWeb, :view

  # Prevent ID collisions if multiple forms are on the page.
  def challenge_name(name) do
    "#{name}_challenge"
  end

  def hcaptcha_site_key do
    Application.get_env(:tsuchinokus, :hcaptcha_site_key)
  end
end
