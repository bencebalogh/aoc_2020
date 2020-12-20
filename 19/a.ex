defmodule AoC do
  def part1() do
    {rules, messages} = get_input()

    options = process(rules, rules[0])

    messages
    |> Enum.filter(&(&1 in options))
    |> Enum.count()
  end

  def part2() do
    {rules, messages} = get_input()

    modified_rules =
      rules
      |> Map.put(8, [42, "|", 42, 8])
      |> Map.put(11, [42, 31, "|", 42, 11, 31])

    options42 = process(modified_rules, rules[42])
    options31 = process(modified_rules, rules[31])

    chunk_sizes = options42 |> hd() |> String.length()

    messages
    |> Enum.filter(fn message ->
      message
      |> chunk(chunk_sizes)
      |> Enum.reduce_while({0, 0}, fn chunk, {rule42, rule31} ->
        case {Enum.member?(options42, chunk), Enum.member?(options31, chunk)} do
          {true, false} when rule31 == 0 -> {:cont, {rule42 + 1, rule31}}
          {false, true} -> {:cont, {rule42, rule31 + 1}}
          _ -> {:halt, {0, 0}}
        end
      end)
      |> case do
        {x, y} when x > 0 and x > y and y > 0 -> true
        _ -> false
      end
    end)
    |> Enum.count()
  end

  defp process(rules, rule) do
    separator =
      rule
      |> Enum.with_index()
      |> Enum.find_value(fn
        {"|", i} -> i
        _ -> false
      end)

    if separator == nil do
      case rule do
        [x] when is_binary(x) ->
          [x]

        [head | []] ->
          process(rules, rules[head])

        [head | tail] ->
          f = process(rules, rules[head])
          bs = Enum.map(tail, fn t -> process(rules, [t]) end)

          variations(f, bs)
      end
    else
      {pre, ["|" | post]} = Enum.split(rule, separator)

      Enum.flat_map([pre, post], fn var ->
        process(rules, var)
      end)
    end
  end

  defp variations(starts, [next | []]),
    do: Enum.flat_map(starts, fn start -> Enum.map(next, fn n -> start <> n end) end)

  defp variations(starts, [next | rest]) do
    Enum.flat_map(starts, fn start ->
      variations(next, rest)
      |> Enum.map(fn calc -> start <> calc end)
    end)
  end

  defp chunk(str, size) do
    str
    |> String.codepoints()
    |> Enum.chunk_every(size)
    |> Enum.map(&Enum.join/1)
  end

  defp get_input() do
    [rules, [""], messages] =
      File.read!("input")
      |> String.trim()
      |> String.split("\n")
      |> Enum.chunk_by(&(&1 == ""))

    parsed_rules =
      rules
      |> Enum.map(&String.split(&1, ":"))
      |> Enum.map(fn
        [rule, definition] ->
          parsed_d =
            definition
            |> String.trim()
            |> String.split(" ")
            |> Enum.map(fn
              "\"a\"" -> "a"
              "\"b\"" -> "b"
              "|" -> "|"
              x -> String.to_integer(x)
            end)

          {String.to_integer(rule), parsed_d}
      end)
      |> Enum.reduce(%{}, fn {r, d}, m -> Map.put(m, r, d) end)

    {parsed_rules, messages}
  end
end
