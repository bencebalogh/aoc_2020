defmodule AoC do
  def part1() do
    get_input()
    |> play()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {nr, i} -> nr * (i + 1) end)
    |> Enum.sum()
  end

  def part2() do
    get_input()
    |> recursive_play({MapSet.new(), MapSet.new()})
    |> case do
      {_player, deck} -> deck
    end
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {nr, i} -> nr * (i + 1) end)
    |> Enum.sum()
  end

  defp play([player1, []]), do: player1
  defp play([[], player2]), do: player2

  defp play(decks) do
    decks
    |> deck_changes()
    |> play()
  end

  defp recursive_play([player1, []], _history), do: {:p1, player1}
  defp recursive_play([[], player2], _history), do: {:p2, player2}

  defp recursive_play(
         [[p1 | t1] = player1, [p2 | t2] = player2] = decks,
         {player1_history, player2_history}
       ) do
    if MapSet.member?(player1_history, player1) || MapSet.member?(player2_history, player2) do
      {:p1, player1}
    else
      t1_count = Enum.count(t1)
      t2_count = Enum.count(t2)

      new_history = {MapSet.put(player1_history, player1), MapSet.put(player2_history, player2)}

      if t1_count >= p1 && t2_count >= p2 do
        new_decks =
          case recursive_play(
                 [Enum.take(t1, p1), Enum.take(t2, p2)],
                 {MapSet.new(), MapSet.new()}
               ) do
            {:p1, _} ->
              [Enum.reverse([p2 | [p1 | Enum.reverse(t1)]]), t2]

            {:p2, _} ->
              [t1, Enum.reverse([p1 | [p2 | Enum.reverse(t2)]])]
          end

        recursive_play(new_decks, new_history)
      else
        new_decks = deck_changes(decks)
        recursive_play(new_decks, new_history)
      end
    end
  end

  defp deck_changes([[p1 | t1], [p2 | t2]]) do
    case {p1, p2} do
      {x, y} when x > y ->
        [Enum.reverse([p2 | [p1 | Enum.reverse(t1)]]), t2]

      {x, y} when x < y ->
        [t1, Enum.reverse([p1 | [p2 | Enum.reverse(t2)]])]
    end
  end

  defp get_input() do
    ["Player 1:\n" <> p1, "Player 2:\n" <> p2] =
      File.read!("input")
      |> String.split("\n\n")

    [p1, p2]
    |> Enum.map(fn player ->
      player
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn i -> String.to_integer(i) end)
    end)
  end
end
