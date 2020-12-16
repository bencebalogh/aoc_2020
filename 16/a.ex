defmodule AoC do
  def part1() do
    input = get_input()

    Enum.map(input[:nearby], &ticket_error_rate(&1, input[:rules])) |> Enum.sum()
  end

  def part2() do
    input = get_input()

    valid_tickets = Enum.filter(input[:nearby], &valid?(&1, input[:rules]))

    valid_tickets
    |> Enum.with_index()
    |> Enum.map(fn {_, index} ->
      positions = Enum.map(valid_tickets, fn t -> Enum.at(t, index) end)
      {find_fitting_rules(positions, input[:rules]), index}
    end)
    |> find_rule()
    |> Map.to_list()
    |> Enum.filter(fn {_index, name} ->
      name |> Atom.to_string() |> String.starts_with?("departure")
    end)
    |> Enum.map(fn {index, _name} -> index end)
    |> Enum.reduce([], fn i, a -> [Enum.at(input[:ticket], i) | a] end)
    |> Enum.reduce(&(&1 * &2))
  end

  defp ticket_error_rate(ticket, rules) do
    just_ranges = Enum.flat_map(rules, fn {_rule, ranges} -> ranges end)

    ticket
    |> Enum.map(fn t ->
      if Enum.find(just_ranges, fn range -> t in range end) == nil do
        t
      else
        0
      end
    end)
    |> Enum.sum()
  end

  defp valid?(ticket, rules) do
    just_ranges = Enum.flat_map(rules, fn {_rule, ranges} -> ranges end)

    ticket
    |> Enum.all?(fn t ->
      Enum.find(just_ranges, fn range -> t in range end) != nil
    end)
  end

  defp find_fitting_rules(positions, rules) do
    Enum.filter(rules, fn {_rule, ranges} ->
      Enum.all?(positions, fn t ->
        Enum.find(ranges, fn range ->
          t in range
        end) != nil
      end)
    end)
  end

  defp find_rule(options, rules \\ %{}) do
    case Enum.find(options, fn {rules, _index} -> Enum.count(rules) == 1 end) do
      {[{name, _ranges} = rule], index} ->
        find_rule(
          Enum.map(options, fn {rules, index} -> {Enum.filter(rules, &(&1 != rule)), index} end),
          Map.put(rules, index, name)
        )

      nil ->
        rules
    end
  end

  defp get_input() do
    str = File.read!("input")

    [rules, rest] = String.split(str, "\n\nyour ticket:\n")
    [ticket, nearby] = String.split(rest, "\n\nnearby tickets:\n")

    %{
      :rules =>
        String.split(rules, "\n")
        |> Enum.map(fn rule ->
          [_match, rule, defs] = Regex.run(~r/([^:]+):\s(.*)/, rule)

          ranges =
            defs
            |> String.split(" or ")
            |> Enum.map(fn r -> String.split(r, "-") |> Enum.map(&String.to_integer/1) end)
            |> Enum.map(fn [s, e] -> Range.new(s, e) end)

          {String.to_atom(rule), ranges}
        end),
      :ticket => ticket |> String.split(",") |> Enum.map(&String.to_integer/1),
      :nearby =>
        nearby
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(fn s -> s |> String.split(",") |> Enum.map(&String.to_integer/1) end)
    }
  end
end
