defmodule AoC do
  def part1() do
    get_input()
    |> Enum.filter(&is_valid?/1)
    |> Enum.count()
  end

  def part2() do
    get_input()
    |> Enum.filter(&is_valid2?/1)
    |> Enum.count()
  end

  defp is_valid?({[min, max], char, pw}) do
    mapped_pw = pw |> String.codepoints() |> Enum.group_by(& &1)

    occurence =
      mapped_pw[char]
      |> case do
        nil -> 0
        c -> Enum.count(c)
      end

    occurence >= min && occurence <= max
  end

  defp is_valid2?({[min, max], char, pw}) do
    list = String.codepoints(pw)
    first = Enum.at(list, min - 1)
    second = Enum.at(list, max - 1)

    (first == char || second == char) && first != second
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " "))
    |> Stream.map(fn [limits, char, pw] ->
      l = limits |> String.split("-") |> Enum.map(&String.to_integer/1)
      {l, String.replace(char, ":", ""), pw}
    end)
    |> Enum.to_list()
  end
end
