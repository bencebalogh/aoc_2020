defmodule AoC do
  @contains_regex ~r/(\d+) (\w+ \w+) bags?[,.]\s*/

  def part1() do
    get_input()
    |> find_all("shiny gold")
    |> Enum.count()
  end

  def part2() do
    get_input()
    |> count_all("shiny gold")
  end

  defp find_all(combinations, color) do
    contains =
      combinations
      |> Map.to_list()
      |> Enum.filter(fn {k, values} -> Enum.find(values, fn {_nr, c} -> c == color end) != nil end)

    colors = Enum.map(contains, fn {color, _info} -> color end)
    colors_new = Enum.flat_map(contains, fn {color, _info} -> find_all(combinations, color) end)

    Enum.uniq(colors ++ colors_new)
  end

  defp count_all(combinations, color) do
    case combinations[color] do
      [] -> 0
      info -> Enum.map(info, fn {nr, c} -> nr + nr * count_all(combinations, c) end) |> Enum.sum()
    end
  end

  def get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line ->
      [b1, b2 | _rest] = String.split(line, " ")

      contains =
        @contains_regex
        |> Regex.scan(line)
        |> Enum.map(fn [_line, nr, color] -> {String.to_integer(nr), color} end)

      %{(b1 <> " " <> b2) => contains}
    end)
    |> Enum.to_list()
    |> Enum.reduce(%{}, &Map.merge(&1, &2))
  end
end
