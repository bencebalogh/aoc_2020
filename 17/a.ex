defmodule AoC do
  def part1() do
    Enum.reduce(0..5, get_input(), fn _, grid -> evolve(grid) end) |> Enum.count()
  end

  def part2() do
    input =
      get_input()
      |> Enum.map(fn {{x, y, z}, :cell} -> {{x, y, z, 0}, :cell} end)
      |> Enum.reduce(%{}, fn {coord, :cell}, g -> Map.put(g, coord, :cell) end)

    Enum.reduce(0..5, input, fn _, grid -> evolve(grid) end) |> Enum.count()
  end

  defp evolve(grid) do
    grid
    |> Map.keys()
    |> Enum.reduce(grid, fn coord, g ->
      g_with_around =
        get_adjacent_coords(coord)
        |> Enum.filter(fn adjacent ->
          get_neighbours(grid, adjacent) |> Enum.count() == 3
        end)
        |> Enum.reduce(g, &Map.put(&2, &1, :cell))

      neighbours = get_neighbours(grid, coord)

      case Enum.count(neighbours) do
        x when x == 2 or x == 3 ->
          g_with_around

        _ ->
          Map.delete(g_with_around, coord)
      end
    end)
  end

  def get_adjacent_coords({x, y, z}) do
    for xx <- [x - 1, x, x + 1],
        yy <- [y - 1, y, y + 1],
        zz <- [z - 1, z, z + 1],
        xx != yy != zz && !(x == xx && y == yy && z == zz),
        do: {xx, yy, zz}
  end

  def get_adjacent_coords({x, y, z, w}) do
    for xx <- [x - 1, x, x + 1],
        yy <- [y - 1, y, y + 1],
        zz <- [z - 1, z, z + 1],
        ww <- [w - 1, w, w + 1],
        xx != yy != zz && !(x == xx && y == yy && z == zz && w == ww),
        do: {xx, yy, zz, ww}
  end

  defp get_neighbours(grid, coords) do
    coords
    |> get_adjacent_coords()
    |> Enum.map(fn coord ->
      case Map.get(grid, coord) do
        :cell -> coord
        _ -> nil
      end
    end)
    |> Enum.filter(&(!match?(nil, &1)))
  end

  defp get_input() do
    File.read!("input")
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, grid ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(grid, fn
        {".", _x}, grid -> grid
        {"#", x}, grid -> Map.put(grid, {x, y, 0}, :cell)
      end)
    end)
  end
end
