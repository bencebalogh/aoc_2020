defmodule AoC do
  @input 158_937_462

  def part1() do
    Enum.reduce(0..99, Zipper.new([], get_circle()), fn _i, zipper ->
      process(zipper)
    end)
    |> case do
      {pre, post} ->
        "#{pre |> Enum.reverse() |> Enum.join("")}#{Enum.join(post, "")}"
        |> String.split("1")
        |> case do
          [before_1, after_1] -> String.trim(after_1) <> String.trim(before_1)
        end
    end
  end

  # stopped here as it'll take forever, check b.ex
  def part2() do
    original_circle = get_circle()
    original_circle_max = Enum.max(original_circle)

    circle =
      (original_circle_max + 1)..1_000_000
      |> Enum.reduce(Enum.reverse(original_circle), fn nr, c -> [nr | c] end)
      |> Enum.reverse()
  end

  defp process(zipper) do
    {current, next_3, current_zipper} = Zipper.pick(zipper)

    destination_cup = find_destination_cup({current, current_zipper})

    Zipper.add_after(current_zipper, destination_cup, next_3, current)
  end

  defp find_destination_cup({current, zipper}) do
    if Zipper.member?(zipper, current - 1) do
      current - 1
    else
      min = Zipper.min(zipper)
      max = Zipper.max(zipper)

      if current - 1 < min do
        find_destination_cup({max + 1, zipper})
      else
        find_destination_cup({current - 1, zipper})
      end
    end
  end

  defp get_circle(), do: Integer.digits(@input)
end

defmodule Zipper do
  def new(pre, post), do: {pre, post}

  def min({[], post}), do: Enum.min(post)
  def min({pre, []}), do: Enum.min(pre)
  def min({pre, post}), do: Enum.min([Enum.min(pre), Enum.min(post)])
  def max({[], post}), do: Enum.max(post)
  def max({pre, []}), do: Enum.max(pre)
  def max({pre, post}), do: Enum.max([Enum.max(pre), Enum.max(post)])

  def member?({pre, post}, nr), do: Enum.member?(pre, nr) || Enum.member?(post, nr)

  def add_after({pre, post}, where, to_add, current) do
    pe =
      pre
      |> Enum.reverse()
      |> Enum.reduce([], fn
        ^where, a ->
          [where | to_add]
          |> Enum.reduce(a, fn add, a2 -> [add | a2] end)

        p, a ->
          [p | a]
      end)

    pt =
      post
      |> Enum.reduce([], fn
        ^where, a ->
          Enum.reduce([where | to_add], a, fn add, a2 -> [add | a2] end)

        p, a ->
          [p | a]
      end)
      |> Enum.reverse()

    {[current | pe], pt}
  end

  def pick({pre, []}) do
    pick({[], Enum.reverse(pre)})
  end

  def pick({pre, [next | post_tail]}) do
    if Enum.count(post_tail) < 3 do
      {next_3, remaining} = pre |> Enum.reverse() |> Enum.split(3 - Enum.count(post_tail))

      moving = post_tail |> Enum.reverse() |> Enum.reduce(next_3, &[&1 | &2])

      {next, moving, {[], remaining}}
    else
      {moving, remaining} = Enum.split(post_tail, 3)
      {next, moving, {pre, remaining}}
    end
  end
end
