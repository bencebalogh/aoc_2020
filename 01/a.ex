defmodule AoC do
  def part1() do
    list = get_input()

    pairs(list)
    |> Enum.find(fn {a, b} -> a + b == 2020 end)
    |> case do
      {a, b} -> a * b
    end
  end

  def part2() do
    list = get_input()

    list
    |> pairs()
    |> Enum.map(fn {a, b} -> {a + b, a * b} end)
    |> Enum.find(fn
      {sum, mul} when sum < 2020 ->
        found = Enum.find(list, fn x -> x + sum == 2020 end)

        if found != nil do
          IO.inspect("#{mul * found}")
          true
        else
          false
        end

      _ ->
        false
    end)
  end

  defp pairs(list) do
    {pairs, _} =
      Enum.reduce(0..(Enum.count(list) - 1), {[], list}, fn _index, {result, shift} ->
        add_to_result = List.flatten([hd(shift) | tl(shift)]) |> Enum.zip(list)
        shifted = List.flatten([tl(shift), hd(shift)])
        {[add_to_result | result], shifted}
      end)

    List.flatten(pairs)
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
