defmodule AoC do
  def part1() do
    input = get_input()

    with_allergens =
      input
      |> Enum.reduce(%{}, fn {ingredients, allergens}, acc ->
        Enum.reduce(allergens, acc, fn alg, acc ->
          ingredients_set = MapSet.new(ingredients)
          Map.update(acc, alg, ingredients_set, &MapSet.intersection(&1, ingredients_set))
        end)
      end)
      |> Map.values()
      |> Enum.reduce(MapSet.new(), fn m, a -> MapSet.union(a, m) end)

    safe =
      input
      |> Enum.flat_map(fn {ingredients, _allergens} -> ingredients end)
      |> Enum.into(MapSet.new())
      |> MapSet.difference(with_allergens)

    input
    |> Enum.flat_map(fn {i, _a} -> i end)
    |> Enum.reduce(0, fn ingredient, count ->
      if MapSet.member?(safe, ingredient) do
        count + 1
      else
        count
      end
    end)
  end

  def part2() do
    input = get_input()

    input
    |> Enum.reduce(%{}, fn {ingredients, allergens}, acc ->
      Enum.reduce(allergens, acc, fn alg, acc ->
        ingredients_set = MapSet.new(ingredients)
        Map.update(acc, alg, ingredients_set, &MapSet.intersection(&1, ingredients_set))
      end)
    end)
    |> build_map()
    |> Map.to_list()
    |> Enum.map(fn {allergen, ingredient} ->
      {allergen, ingredient |> MapSet.to_list() |> hd()}
    end)
    |> Enum.sort_by(fn {a, _i} -> a end)
    |> Enum.map(fn {_a, i} -> i end)
    |> Enum.join(",")
  end

  # very ineffective, but hey
  defp build_map(map) do
    not_defined =
      map
      |> Map.to_list()
      |> Enum.filter(fn {_allergen, options} -> Enum.count(options) > 1 end)

    if Enum.count(not_defined) == 0 do
      map
    else
      defined =
        map
        |> Map.to_list()
        |> Enum.filter(fn {_allergen, options} -> Enum.count(options) == 1 end)

      defined_ingredients = Enum.map(defined, fn {_allergen, ingredient} -> ingredient end)

      defined_map = Enum.reduce(defined, %{}, fn {a, i}, m -> Map.put(m, a, i) end)

      new =
        not_defined
        |> Enum.map(fn {allergen, options} ->
          {allergen, Enum.reduce(defined_ingredients, options, &MapSet.difference(&2, &1))}
        end)
        |> Enum.reduce(%{}, fn {a, i}, m -> Map.put(m, a, i) end)

      build_map(Map.merge(new, defined_map))
    end
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [_, ingredients, allergens] = Regex.run(~r/([^(]*)\(contains ([^)]*)\)/, s)
      {String.trim(ingredients) |> String.split(" "), String.split(allergens, ", ")}
    end)
    |> Enum.to_list()
  end
end
