defmodule AoC do
  @keys [
    "byr",
    "iyr",
    "eyr",
    "hgt",
    "hcl",
    "ecl",
    "pid"
  ]

  def part1() do
    get_input()
    |> Enum.map(&convert_to_map/1)
    |> Enum.filter(&has_all_keys?/1)
    |> Enum.count()
  end

  def part2() do
    get_input()
    |> Enum.map(&convert_to_map/1)
    |> Enum.filter(&is_valid?/1)
    |> Enum.count()
  end

  defp convert_to_map(details) do
    details
    |> Enum.map(fn str ->
      str
      |> String.split(" ")
      |> Enum.map(&String.split(&1, ":"))
      |> Enum.reduce(%{}, fn [k, v], a -> Map.put(a, k, v) end)
    end)
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.filter(&(&1 != [""]))
  end

  defp has_all_keys?(passport), do: Enum.all?(@keys, fn key -> Map.has_key?(passport, key) end)

  defp is_valid?(passport) do
    has_all_keys?(passport) &&
      passport
      |> Map.to_list()
      |> Enum.all?(fn
        {"byr", v} -> byr_validation(String.to_integer(v))
        {"iyr", v} -> iyr_validation(String.to_integer(v))
        {"eyr", v} -> eyr_validation(String.to_integer(v))
        {"hgt", v} -> hgt_validation(v)
        {"hcl", v} -> hcl_validation(v)
        {"ecl", v} -> ecl_validation(v)
        {"pid", v} -> pid_validation(v)
        {"cid", _} -> true
      end)
  end

  defp byr_validation(x), do: x >= 1920 && x <= 2002
  defp iyr_validation(x), do: x >= 2010 && x <= 2020
  defp eyr_validation(x), do: x >= 2020 && x <= 2030

  defp hgt_validation(x) do
    if String.contains?(x, "cm") do
      i = String.replace(x, "cm", "") |> String.to_integer()
      i >= 150 && i <= 193
    else
      if String.contains?(x, "in") do
        i = String.replace(x, "in", "") |> String.to_integer()
        i >= 59 && i <= 76
      else
        false
      end
    end
  end

  defp hcl_validation("#" <> x), do: Regex.match?(~r/^[0-9a-f]{6}$/, x)
  defp hcl_validation(_x), do: false

  defp ecl_validation(x), do: Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], x)

  defp pid_validation(x), do: Regex.match?(~r/^[0-9]{9}$/, x)
end
