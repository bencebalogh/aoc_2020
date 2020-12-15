defmodule AoC do
  def part1() do
    run(2020)
  end

  def part2() do
    run(30_000_000)
  end

  defp run(last) do
    input = get_input()
    start = (input |> Map.keys() |> Enum.count()) + 1

    {_map, _next, res} =
      Enum.reduce(start..last, {input, 0, nil}, fn index, {map, next, _res} ->
        if Map.has_key?(map, next) do
          {Map.put(map, next, index), index - map[next], next}
        else
          if index == last do
            {Map.put(map, next, index), 0, next}
          else
            {Map.put(map, next, index), 0, 0}
          end
        end
      end)

    res
  end

  defp get_input() do
    File.read!("input")
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {nr, i} -> {nr, i + 1} end)
    |> Enum.reduce(%{}, fn {nr, i}, m -> Map.put(m, nr, i) end)
  end
end
