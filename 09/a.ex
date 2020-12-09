defmodule AoC do
  @amble 25

  def part1() do
    get_input()
    |> find_missing(@amble)
    |> case do
      {n, _index} -> n
    end
  end

  def part2() do
    nrs = get_input()
    {sum, index} = find_missing(nrs, @amble)

    nrs
    |> Enum.take(index - 1)
    |> find_sum(sum)
    |> Enum.min_max()
    |> case do
      {min, max} -> min + max
    end
  end

  defp find_missing(nrs, index) do
    if check_nr(nrs, index) do
      {Enum.at(nrs, index), index}
    else
      find_missing(nrs, index + 1)
    end
  end

  defp check_nr(nrs, index) do
    nr = Enum.at(nrs, index)
    pre = nrs |> Enum.take(index) |> Enum.reverse() |> Enum.take(@amble)

    pre
    |> Enum.with_index()
    |> Enum.find(fn {p, i} ->
      pre |> List.delete_at(i) |> Enum.find(&(&1 + p == nr)) != nil
    end) == nil
  end

  defp find_sum(nrs, sum) do
    nrs
    |> Enum.with_index()
    |> Enum.find_value(fn {_nr, i} ->
      {outcome, _s, elems} =
        nrs
        |> Enum.drop(i)
        |> Enum.reduce_while({:notfound, 0, []}, fn x, {:notfound, agg, elems} ->
          s = agg + x

          case s do
            _a when s > sum -> {:halt, {:failed, s, [x | elems]}}
            _a when s == sum -> {:halt, {:success, s, [x | elems]}}
            _a -> {:cont, {:notfound, s, [x | elems]}}
          end
        end)

      if outcome == :success do
        elems
      else
        false
      end
    end)
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
