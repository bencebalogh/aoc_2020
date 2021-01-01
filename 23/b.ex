defmodule AoC do
  @input 158_937_462
  @to 1_000_000
  @rounds 10_000_000

  def part2() do
    original = get_circle()

    circle = :atomics.new(@to, [])

    Enum.zip(original, tl(original) ++ [10])
    |> Enum.each(fn {nr, next} -> :atomics.put(circle, nr, next) end)

    Enum.each(10..@to, fn i -> :atomics.put(circle, i, i + 1) end)
    :atomics.put(circle, @to, hd(original))

    Enum.reduce(0..(@rounds - 1), {hd(original), circle}, fn _i, info -> process(info) end)
    |> answer()
  end

  defp process({current, circle}) do
    moving_1 = :atomics.get(circle, current)
    moving_2 = :atomics.get(circle, moving_1)
    moving_3 = :atomics.get(circle, moving_2)
    next = :atomics.get(circle, moving_3)

    :atomics.put(circle, current, next)

    destination_cup = find_destination_cup(circle, [current, moving_1, moving_2, moving_3])

    after_destination_cup = :atomics.get(circle, destination_cup)
    :atomics.put(circle, moving_3, after_destination_cup)
    :atomics.put(circle, destination_cup, moving_1)

    {next, circle}
  end

  defp find_destination_cup(circle, [1 | moving]),
    do: find_destination_cup(circle, [@to + 1 | moving])

  defp find_destination_cup(circle, [current | moving]) do
    p = current - 1

    if Enum.member?(moving, p) do
      find_destination_cup(circle, [current - 1 | moving])
    else
      p
    end
  end

  defp answer({_, circle}) do
    next = :atomics.get(circle, 1)
    after_next = :atomics.get(circle, next)

    next * after_next
  end

  defp get_circle(), do: Integer.digits(@input)
end
