defmodule Tsuchinokus.Config do
  def get(key) do
    Application.get_env(:tsuchinokus, :config)[key]
  end
end
