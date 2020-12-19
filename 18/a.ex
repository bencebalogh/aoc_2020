defmodule AoC do
  def part1() do
    get_input()
    |> Stream.map(fn line ->
      line
      |> String.replace(" ", "")
      |> String.codepoints()
      |> Enum.map(fn
        operation when operation in ["+", "*", "(", ")"] -> operation
        int -> String.to_integer(int)
      end)
      |> parse()
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  def part2() do
    get_input()
    |> Stream.map(fn line ->
      line
      |> String.replace(" ", "")
      |> String.codepoints()
      |> Enum.map(fn
        operation when operation in ["+", "*", "(", ")"] -> operation
        int -> String.to_integer(int)
      end)
      |> parse2([])
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  defp parse(["(" | tail]) do
    {res, remaining} = parse(tail)
    parse([res | remaining])
  end

  defp parse(input), do: process(hd(input), tl(input))

  defp process(nr, []), do: nr

  defp process(nr, ["+", "(" | tail]) do
    {res, remaining} = parse(tail)
    parse([nr + res | remaining])
  end

  defp process(nr, ["*", "(" | tail]) do
    {res, remaining} = parse(tail)
    parse([nr * res | remaining])
  end

  defp process(nr, [")" | tail]), do: {nr, tail}

  defp process(nr, ["+", nr2 | tail]), do: process(nr + nr2, tail)
  defp process(nr, ["*", nr2 | tail]), do: process(nr * nr2, tail)

  defp parse2([], parsed), do: Enum.reverse(parsed) |> calc()

  defp parse2(["(" | tail], parsed) do
    {within, remains} = found_next_p(tail)
    parse2(remains, [within | parsed])
  end

  defp parse2([head | tail], parsed) do
    parse2(tail, [head | parsed])
  end

  defp found_next_p(list) do
    next =
      Enum.reduce_while(list, {0, []}, fn
        ")", {d, found} when d == 0 -> {:halt, Enum.reverse(found)}
        ")", {d, found} -> {:cont, {d - 1, [")" | found]}}
        "(", {d, found} -> {:cont, {d + 1, ["(" | found]}}
        x, {d, found} -> {:cont, {d, [x | found]}}
      end)

    value = parse2(next, [])

    remaining = Enum.drop(list, Enum.count(next) + 1)

    {value, remaining}
  end

  defp calc([res]), do: res

  defp calc(list) do
    case list |> Enum.with_index() |> Enum.find(&match?({"+", _}, &1)) do
      {"+", i} ->
        {pre, [nr1, "+", nr2 | post]} = Enum.split(list, i - 1)
        calc(pre ++ [nr1 + nr2] ++ post)

      nil ->
        case list |> Enum.with_index() |> Enum.find(&match?({"*", _}, &1)) do
          {"*", i} ->
            {pre, [nr1, "*", nr2 | post]} = Enum.split(list, i - 1)
            calc(pre ++ [nr1 * nr2] ++ post)
        end
    end
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
  end
end
