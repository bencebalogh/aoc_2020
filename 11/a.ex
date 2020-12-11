defmodule AoC do
  @directions [{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}]

  def part1() do
    get_input()
    |> arrange()
    |> Map.values()
    |> Enum.filter(&(&1 == "#"))
    |> Enum.count()
  end

  def part2() do
    get_input()
    |> arrange2()
    |> Map.values()
    |> Enum.filter(&(&1 == "#"))
    |> Enum.count()
  end

  defp arrange(grid, steps \\ 0) do
    new_grid = do_round(grid)
    if new_grid == grid do
      grid
    else
      arrange(new_grid, steps + 1)
    end
  end

  defp arrange2(grid, steps \\ 0) do
    new_grid = do_round2(grid)
    if new_grid == grid do
      grid
    else
      arrange2(new_grid, steps + 1)
    end
  end

  defp do_round(grid) do
    grid
    |> Map.to_list()
    |> Enum.reduce(grid, fn
      {coords, "L"}, result ->
        get_adjacent(grid, coords)
        |> Enum.all?(&(&1 != "#"))
        |> case do
             true -> Map.put(result, coords, "#")
             false -> result
           end
      {coords, "#"}, result ->
        get_adjacent(grid, coords)
        |> Enum.filter(&(&1 == "#"))
        |> Enum.count()
        |> case do
             x when x >= 4 -> Map.put(result, coords, "L")
             _ -> result
           end
      {_coords, "."}, result ->
        result
    end)
  end

  defp do_round2(grid) do
    grid
    |> Map.to_list()
    |> Enum.reduce(grid, fn
      {{x, y} = coords, "L"}, result ->
        visible(grid, x, y)
        |> Enum.filter(fn elem -> elem == "#" end)
        |> Enum.count()
        |> case do
             0 -> Map.put(result, coords, "#")
             _ -> result
            end
      {{x, y} = coords, "#"}, result ->
        visible(grid, x, y)
        |> Enum.filter(fn elem -> elem == "#" end)
        |> Enum.count()
        |> case do
             x when x >= 5 -> Map.put(result, coords, "L")
             _ -> result
            end
      {_coords, "."}, result ->
        result
    end)
  end

  def visible(grid, x, y) do
    Enum.reduce(
      @directions,
      [],
      fn {shift_x, shift_y}, acc ->
        Stream.cycle([0])
        |> Enum.reduce_while({acc, x, y}, fn _, {acc, x, y} ->
          {new_x, new_y} = {x + shift_x, y + shift_y}

          case Map.get(grid, {new_x, new_y}) do
            "." -> {:cont, {acc, new_x, new_y}}
            nil -> {:halt, acc}
            seat -> {:halt, [seat | acc]}
          end
        end)
      end
    )
  end

  defp draw(grid) do
    IO.inspect("--")
    grid
    |> Map.to_list()
    |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} -> x1 < x2 || (x1 == x2 && y1 < y2) end)
    |> Enum.reduce({0, ""}, fn {{x, _y}, elem}, {row_index, row} ->
      if row_index == x do
        {row_index, row <> elem}
      else
        IO.inspect row
        {row_index + 1, elem}
      end
    end)
    |> case do
         {_, last_row} -> IO.inspect(last_row)
       end

    grid
  end

  defp get_adjacent(grid, {x, y}) do
    [
      Map.get(grid, {x - 1, y - 1}),
      Map.get(grid, {x - 1, y}),
      Map.get(grid, {x + 1, y - 1}),
      Map.get(grid, {x + 1, y}),
      Map.get(grid, {x + 1, y + 1}),
      Map.get(grid, {x, y + 1}),
      Map.get(grid, {x - 1, y + 1}),
      Map.get(grid, {x, y - 1})
    ]
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, grid ->
      row
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {elem, column_index}, grid -> Map.put(grid, {row_index, column_index}, elem) end)
    end)
  end
end
