defmodule AoC do
  @questions ?a..?z |> Enum.map(&<<&1::utf8>>)

  def part1() do
    get_input()
    |> Enum.map(fn group ->
      group
      |> Enum.flat_map(&String.codepoints/1)
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part2() do
    get_input()
    |> Enum.map(fn group ->
      group
      |> Enum.map(&String.codepoints/1)
      |> Enum.reduce(@questions, fn g, a ->
        Set.intersection(Enum.into(a, HashSet.new()), Enum.into(g, HashSet.new()))
      end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.filter(&(&1 != [""]))
  end
end
