defmodule Tsuchinokus.Analyzers.Svg do
  def analyze(file) do
    stats = stats(file)

    %{
      extension: "svg",
      mime_type: "image/svg+xml",
      animated?: false,
      duration: 0.0,
      dimensions: stats.dimensions
    }
  end

  defp stats(file) do
    case System.cmd("svgstat", [file]) do
      {output, 0} ->
        [_size, _frames, width, height, _num, _den] =
          output
          |> String.trim()
          |> String.split(" ")
          |> Enum.map(&String.to_integer/1)

        %{dimensions: {width, height}}

      _ ->
        %{dimensions: {0, 0}}
    end
  end
end
