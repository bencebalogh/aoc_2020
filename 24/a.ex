defmodule AoC do
  def part1() do
    get_input()
    |> Enum.reduce(%{}, fn changes, tiles ->
      tile = Enum.reduce(changes, {0, 0}, &move_to/2)

      flip(tiles, tile)
    end)
    |> Map.values()
    |> Enum.count()
  end

  def part2() do
    start =
      get_input()
      |> Enum.reduce(%{}, fn changes, tiles ->
        tile = Enum.reduce(changes, {0, 0}, &move_to/2)

        flip(tiles, tile)
      end)

    Enum.reduce(0..99, start, fn _day, tiles -> evolve(tiles) end)
    |> Map.values()
    |> Enum.count()
  end

  defp get_adjacent(tiles, coord) do
    ["nw", "ne", "w", "e", "sw", "se"]
    |> Enum.map(fn direction -> move_to(direction, coord) end)
    |> Enum.map(fn c ->
      case Map.get(tiles, c) do
        nil -> {c, :white}
        v -> {c, v}
      end
    end)
  end

  defp evolve(tiles) do
    with_surroundings =
      tiles
      |> Map.to_list()
      |> Enum.flat_map(fn {coord, color} ->
        [{coord, color} | get_adjacent(tiles, coord)]
      end)
      |> Enum.reduce(%{}, fn {coord, color}, map -> Map.put(map, coord, color) end)

    with_surroundings
    |> Map.to_list()
    |> Enum.map(fn
      {coord, :black} ->
        case get_adjacent(with_surroundings, coord)
             |> Enum.filter(fn {_, color} -> color == :black end)
             |> Enum.count() do
          x when x == 0 or x > 2 ->
            {coord, :white}

          _ ->
            {coord, :black}
        end

      {coord, :white} ->
        case get_adjacent(with_surroundings, coord)
             |> Enum.filter(fn {_, color} -> color == :black end)
             |> Enum.count() do
          2 ->
            {coord, :black}

          _ ->
            {coord, :white}
        end
    end)
    |> Enum.reduce(%{}, fn
      {coord, :black}, map -> Map.put(map, coord, :black)
      {coord, :white}, map -> map
    end)
  end

  defp move_to("nw", {x, y}), do: {x, y + 1}
  defp move_to("ne", {x, y}), do: {x + 1, y}
  defp move_to("w", {x, y}), do: {x - 1, y + 1}
  defp move_to("e", {x, y}), do: {x + 1, y - 1}
  defp move_to("sw", {x, y}), do: {x - 1, y}
  defp move_to("se", {x, y}), do: {x, y - 1}

  defp flip(tiles, coords) do
    case Map.get(tiles, coords) do
      :black -> Map.delete(tiles, coords)
      :white -> Map.put(tiles, coords, :black)
      nil -> Map.put(tiles, coords, :black)
    end
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Stream.map(&transform(&1, []))
    |> Stream.map(&Enum.reverse/1)
    |> Enum.to_list()
  end

  defp transform([], directions), do: directions
  defp transform([head | []], directions), do: [head | directions]

  defp transform([head | [next | tail]], directions) do
    case {head, next} do
      {"n", "e"} ->
        transform(tail, ["ne" | directions])

      {"n", "w"} ->
        transform(tail, ["nw" | directions])

      {"s", "e"} ->
        transform(tail, ["se" | directions])

      {"s", "w"} ->
        transform(tail, ["sw" | directions])

      _ ->
        transform([next | tail], [head | directions])
    end
  end
end
