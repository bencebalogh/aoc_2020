defmodule AoC do
  def part1() do
    get_input()
    |> Stream.map(fn s ->
      {{row, row}, {seat, sear}} =
        s
        |> String.codepoints()
        |> Enum.reduce({{0, 127}, {0, 7}}, &get_row_column/2)

      row * 8 + seat
    end)
    |> Enum.to_list()
    |> Enum.max()
  end

  def part2() do
    seat_ids =
      get_input()
      |> Stream.map(fn s ->
        {{row, row}, {seat, sear}} =
          s
          |> String.codepoints()
          |> Enum.reduce({{0, 127}, {0, 7}}, &get_row_column/2)

        row * 8 + seat
      end)
      |> Enum.to_list()

    Enum.min(seat_ids)..Enum.max(seat_ids)
    |> Enum.find(&(!Enum.member?(seat_ids, &1)))
  end

  defp get_row_column("B", {{lr, hr}, columns}) do
    {{div(hr + lr, 2) + 1, hr}, columns}
  end

  defp get_row_column("F", {{lr, hr}, columns}) do
    {{lr, div(hr + lr, 2)}, columns}
  end

  defp get_row_column("R", {rows, {lc, hc}}) do
    {rows, {div(hc + lc, 2) + 1, hc}}
  end

  defp get_row_column("L", {rows, {lc, hc}}) do
    {rows, {lc, div(hc + lc, 2)}}
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
  end
end
