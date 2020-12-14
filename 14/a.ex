defmodule AoC do
  def part1() do
    get_input()
    |> Enum.reduce({nil, %{}}, fn
      "mask = " <> mask, {_prev_mask, memory} ->
        {mask
         |> String.codepoints()
         |> Enum.with_index()
         |> Enum.filter(&(!match?({"X", _}, &1))), memory}

      line, {mask, memory} ->
        [_line, address, value] = Regex.run(~r/^mem\[(\d+)\]\s=\s(\d+)$/, line)

        value_binary =
          value |> String.to_integer() |> Integer.to_string(2) |> String.pad_leading(36, "0")

        address = String.to_integer(address)

        calculated =
          Enum.reduce(mask, value_binary, fn {v, a}, value -> replace_at(value, a, v) end)

        {mask, Map.put(memory, address, calculated)}
    end)
    |> case do
      {_mask, memory} -> memory
    end
    |> Map.values()
    |> Enum.map(&String.to_integer(&1, 2))
    |> Enum.sum()
  end

  def part2() do
    get_input()
    |> Enum.reduce({nil, %{}}, fn
      "mask = " <> mask, {_prev_mask, memory} ->
        {mask |> String.codepoints() |> Enum.with_index(), memory}

      line, {mask, memory} ->
        [_line, address, value] = Regex.run(~r/^mem\[(\d+)\]\s=\s(\d+)$/, line)

        value_int = String.to_integer(value)

        address_binary =
          address |> String.to_integer() |> Integer.to_string(2) |> String.pad_leading(36, "0")

        address = String.to_integer(address)

        calculated =
          Enum.reduce(mask, address_binary, fn
            {"0", _a}, value -> value
            {v, a}, value -> replace_at(value, a, v)
          end)

        new_memory =
          get_variations(calculated)
          |> Enum.map(&String.to_integer(&1, 2))
          |> Enum.reduce(memory, &Map.put(&2, &1, value_int))

        {mask, new_memory}
    end)
    |> case do
      {_mask, memory} -> memory
    end
    |> Map.values()
    |> Enum.sum()
  end

  defp replace_at(string, index, char) do
    {pre, <<_replacing::binary-size(1), post::binary>>} = String.split_at(string, index)
    pre <> char <> post
  end

  def get_variations(string) do
    Enum.flat_map(["0", "1"], fn v ->
      {index, 1} = :binary.match(string, "X")
      variation = replace_at(string, index, v)

      if String.contains?(variation, "X") do
        get_variations(variation)
      else
        [variation]
      end
    end)
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end
end
