defmodule AoC do
  @key 14_082_811
  @door 5_249_543

  def part1() do
    key_loop_size = find_loop_size(@key, 1, 1)

    {key, _} =
      Enum.reduce(0..(key_loop_size - 1), {1, @door}, fn _i, {value, subject} ->
        {loop(value, subject), subject}
      end)

    key
  end

  defp loop(value, subject), do: rem(value * subject, 20_201_227)

  defp find_loop_size(result, value, loop) do
    r = loop(value, 7)

    if r == result do
      loop
    else
      find_loop_size(result, r, loop + 1)
    end
  end
end
