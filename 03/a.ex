defmodule AoC do
  def part1() do
    input = get_input()
    move(input, {0, 0})
  end

  def part2() do
    input = get_input()

    movement_options = [
      {1, 1},
      {3, 1},
      {5, 1},
      {7, 1},
      {1, 2}
    ]

    movement_options
    |> Enum.map(fn {x, y} -> move(input, {0, 0}, 0, x, y) end)
    |> Enum.reduce(&(&1 * &2))
  end

  defp move(grid, {x, y}, counter \\ 0, movement_x \\ 3, movement_y \\ 1) do
    max_y = Enum.count(grid) - 1
    max_x = Enum.count(hd(grid)) - 1

    new_x =
      if x + movement_x < max_x do
        x + movement_x
      else
        x + movement_x - max_x - 1
      end

    new_y = y + movement_y

    counter =
      if grid |> Enum.at(new_y) |> Enum.at(new_x) == "#" do
        counter + 1
      else
        counter
      end

    if new_y == max_y do
      counter
    else
      move(grid, {new_x, new_y}, counter, movement_x, movement_y)
    end
  end

  def get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list()
  end
end
