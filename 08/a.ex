defmodule AoC do
  def part1() do
    get_input()
    |> process(0, 0, MapSet.new())
    |> case do
      {:seen, acc} -> acc
    end
  end

  def part2() do
    get_input()
    |> modify_and_process(MapSet.new())
  end

  defp process(steps, index, acc, seen) do
    if MapSet.member?(seen, index) do
      {:seen, acc}
    else
      case Enum.at(steps, index) do
        {:acc, arg} -> process(steps, index + 1, acc + arg, MapSet.put(seen, index))
        {:nop, _arg} -> process(steps, index + 1, acc, MapSet.put(seen, index))
        {:jmp, arg} -> process(steps, index + arg, acc, MapSet.put(seen, index))
        nil -> {:finished, acc}
      end
    end
  end

  defp modify_and_process(steps, tried) do
    {{exit_cause, acc}, index} =
      case steps
           |> Enum.with_index()
           |> Enum.find(fn {{cmd, _}, index} ->
             (cmd == :nop || cmd == :jmp) && !Enum.member?(tried, index)
           end) do
        {{:nop, arg}, index} ->
          finished = steps |> List.replace_at(index, {:jmp, arg}) |> process(0, 0, MapSet.new())
          {finished, index}

        {{:jmp, arg}, index} ->
          finished = steps |> List.replace_at(index, {:nop, arg}) |> process(0, 0, MapSet.new())
          {finished, index}
      end

    if exit_cause == :finished do
      acc
    else
      modify_and_process(steps, MapSet.put(tried, index))
    end
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " "))
    |> Stream.map(fn [cmd, arg] -> {String.to_atom(cmd), String.to_integer(arg)} end)
    |> Enum.to_list()
  end
end
