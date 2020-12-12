defmodule AoC do
  def part1() do
    get_input()
    |> Stream.scan({:E, {0, 0}}, &move/2)
    |> Enum.to_list()
    |> Enum.reverse()
    |> hd()
    |> case do
      {_facing, {x, y}} -> abs(x) + abs(y)
    end
  end

  def part2() do
    get_input()
    |> Stream.scan({:E, {10, 1}, {0, 0}}, &waypoint/2)
    |> Enum.to_list()
    |> Enum.reverse()
    |> hd()
    |> case do
      {_facing, _waypoint, {x, y}} -> abs(x) + abs(y)
    end
  end

  defp move({:E, arg}, {facing, {x, y}}), do: {facing, {x + arg, y}}
  defp move({:W, arg}, {facing, {x, y}}), do: {facing, {x - arg, y}}
  defp move({:N, arg}, {facing, {x, y}}), do: {facing, {x, y + arg}}
  defp move({:S, arg}, {facing, {x, y}}), do: {facing, {x, y - arg}}

  defp move({:F, arg}, {facing, _coords} = state), do: move({facing, arg}, state)

  defp move({:L, degree}, state), do: turn([:E, :N, :W, :S], degree, state)
  defp move({:R, degree}, state), do: turn([:E, :S, :W, :N], degree, state)

  defp turn(directions, degree, {facing, coords}) do
    new_facing =
      directions
      |> Stream.cycle()
      |> Stream.drop_while(&(&1 != facing))
      |> Stream.take(div(degree, 90) + 1)
      |> Enum.to_list()
      |> Enum.reverse()
      |> hd()

    {new_facing, coords}
  end

  defp waypoint({:E, arg}, {facing, {w_x, w_y}, ship_coords}),
    do: {facing, {w_x + arg, w_y}, ship_coords}

  defp waypoint({:W, arg}, {facing, {w_x, w_y}, ship_coords}),
    do: {facing, {w_x - arg, w_y}, ship_coords}

  defp waypoint({:N, arg}, {facing, {w_x, w_y}, ship_coords}),
    do: {facing, {w_x, w_y + arg}, ship_coords}

  defp waypoint({:S, arg}, {facing, {w_x, w_y}, ship_coords}),
    do: {facing, {w_x, w_y - arg}, ship_coords}

  defp waypoint({:F, arg}, {facing, {w_x, w_y} = waypoint_coords, {s_x, s_y}}) do
    {facing, waypoint_coords, {s_x + w_x * arg, s_y + w_y * arg}}
  end

  defp waypoint({:L, arg}, {facing, waypoint_coords, ship_coords}) do
    {facing, rotate_waypoint_left(div(arg, 90), waypoint_coords), ship_coords}
  end

  defp waypoint({:R, arg}, {facing, waypoint_coords, ship_coords}) do
    {facing, rotate_waypoint_right(div(arg, 90), waypoint_coords), ship_coords}
  end

  defp rotate_waypoint_left(0, {w_x, w_y}), do: {w_x, w_y}

  defp rotate_waypoint_left(steps, {w_x, w_y}),
    do: rotate_waypoint_left(steps - 1, {w_y * -1, w_x})

  defp rotate_waypoint_right(0, {w_x, w_y}), do: {w_x, w_y}

  defp rotate_waypoint_right(steps, {w_x, w_y}),
    do: rotate_waypoint_right(steps - 1, {w_y, w_x * -1})

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn <<head::binary-size(1), rest::binary>> ->
      {String.to_atom(head), String.to_integer(rest)}
    end)
  end
end
