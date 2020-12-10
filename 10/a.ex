defmodule AoC do
  def part1() do
    adapters = get_input()
    |> use_all_adapters(0, [])
    |> Enum.map(fn {_adapter, diff} -> diff end)
    |> Enum.group_by(&(&1))

    Enum.count(adapters[1]) * (Enum.count(adapters[3]) + 1)
  end

  def part2() do
    input = get_input()

    adapter_combinations(input, 0, %{})
    |> count()
    |> case do
         {count, _} -> count
       end
  end

  defp use_all_adapters(%MapSet{map: m}, _jolt, used) when map_size(m) == 0, do: used
  defp use_all_adapters(adapters, jolt, used) do
    picked = adapters |> filter_adapters(jolt) |> Enum.min()
    diff = picked - jolt

    if picked != nil do
      use_all_adapters(MapSet.delete(adapters, picked), picked, [{picked, diff} | used])
    else
      used
    end
  end

  defp adapter_combinations(adapters, jolt, chains) do
    if Map.has_key?(chains, jolt) do
      chains
    else
      case filter_adapters(adapters, jolt) do
        [ pick | [] ] ->
          adapter_combinations(MapSet.delete(adapters, pick), pick, Map.put(chains, jolt, [pick]))
        [] ->
          chains
        options ->
          new_chains = Map.put(chains, jolt, options)
          Enum.reduce(options, new_chains, fn o, c ->
            adapter_combinations(MapSet.delete(adapters, o), o, c)
          end)
      end
    end
  end

  defp count(combinations, index \\ 0, cache \\ %{}, sum \\ 0) do
    if !Map.has_key?(combinations, index) do
      {1, cache}
    else
      options = combinations[index]

      Enum.reduce(options, {sum, cache}, fn o, {s, c} ->
        if Map.has_key?(c, o) do
          {c[o] + s, c}
        else
          {result, cache2} = count(combinations, o, c, s)
          updated_cache = Map.put(cache2, o, result)
          {result + s, updated_cache}
        end
      end)

    end
  end

  defp filter_adapters(adapters, jolt), do: Enum.filter(adapters, &(&1 > jolt && &1 - jolt <= 3))

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
    |> Enum.sort()
    |> Enum.into(MapSet.new())
  end
end
