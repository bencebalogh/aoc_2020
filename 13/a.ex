defmodule AoC do
  def part1() do
    {start, schedules} = get_input()

    no_cancelled = Enum.filter(schedules, fn s -> s != :cancelled end)

    [start]
    |> Stream.cycle()
    |> Enum.reduce_while(start, fn _, min ->
      no_cancelled
      |> Enum.find(fn m -> rem(min, m) == 0 end)
      |> case do
        nil -> {:cont, min + 1}
        x -> {:halt, (min - start) * x}
      end
    end)
  end

  def part2() do
    {_start, schedules} = get_input()

    schedules
    |> Enum.with_index()
    |> Enum.filter(&(!match?({:cancelled, _}, &1)))
    |> find_next(0, 1, [])
  end

  defp find_next([], t, _steps, _checked), do: t

  defp find_next([head | tail], t, steps, checked) do
    new_checked = [head | checked]

    {new_steps, new_checked, min} =
      [t]
      |> Stream.cycle()
      |> Enum.reduce_while(t, fn _, min ->
        new_checked
        |> Enum.all?(fn {id, delay} -> rem(min + delay, id) == 0 end)
        |> case do
          true ->
            new_steps = new_checked |> Enum.map(fn {id, _} -> id end) |> Enum.reduce(&(&1 * &2))
            {:halt, {new_steps, new_checked, min}}

          false ->
            {:cont, min + steps}
        end
      end)

    find_next(tail, min, new_steps, new_checked)
  end

  def get_input() do
    File.read!("input")
    |> String.trim()
    |> String.split("\n")
    |> case do
      [start, schedules] ->
        schedules
        |> String.split(",")
        |> Enum.map(fn
          "x" -> :cancelled
          s -> String.to_integer(s)
        end)
        |> case do
          parsed -> {String.to_integer(start), parsed}
        end
    end
  end
end
