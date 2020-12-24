defmodule AoC do
  @moduledoc """
  Somewhere along this solution I descended into madness and decided to embrace it. In an attempt to clean things up in the end I also managed to lose the part which finds the monsters,
  already so tired of this so only pushed the part which is building the image.

  The code is an incomprehensible mess, ugly, unefficient and incredibly slow as well.
  """

  # 0 indexed
  @tile_size 9

  @variations %{
    0 => :left_horizontal,
    1 => :left,
    2 => :right_horizontal,
    3 => :right,
    4 => :horizontal,
    5 => :vertical,
    6 => :tile
  }
  @variations2 %{
    6 => :left_horizontal,
    5 => :left,
    4 => :right_horizontal,
    3 => :right,
    2 => :horizontal,
    1 => :vertical,
    0 => :tile
  }

  def part1() do
    borders_only =
      get_input()
      |> Enum.map(fn {id, tile} ->
        right_rotated = rotate_tile_right(tile)

        horizontal_mirrored = rotate_tile_right(right_rotated)

        left_rotated = rotate_tile_right(horizontal_mirrored)

        vertical_mirorred = mirror_tile(tile, :vertical, @tile_size)

        variations = [
          tile,
          vertical_mirorred,
          horizontal_mirrored,
          right_rotated,
          mirror_tile(right_rotated, :horizontal, @tile_size),
          left_rotated,
          mirror_tile(left_rotated, :horizontal, @tile_size)
        ]

        {id, variations}
      end)
      |> Enum.map(fn {id, variations} ->
        borders_only =
          Enum.map(variations, fn tile ->
            tile
            |> Map.to_list()
            |> Enum.filter(fn {{x, y}, _c} ->
              x == 0 || y == 0 || x == @tile_size || y == @tile_size
            end)
          end)
          |> Enum.reduce([], fn variation_borders, agg ->
            res =
              Map.put(%{}, :top, variation_borders |> Enum.filter(fn {{_x, y}, _c} -> y == 0 end))
              |> Map.put(:left, variation_borders |> Enum.filter(fn {{x, _y}, _c} -> x == 0 end))
              |> Map.put(
                :right,
                variation_borders |> Enum.filter(fn {{x, _y}, _c} -> x == @tile_size end)
              )
              |> Map.put(
                :bottom,
                variation_borders |> Enum.filter(fn {{_x, y}, _c} -> y == @tile_size end)
              )

            [res | agg]
          end)
          |> Enum.map(fn map ->
            map
            |> Map.to_list()
            |> Enum.map(fn {place, row} ->
              {place,
               row
               |> Enum.sort(fn {{x1, y1}, _c1}, {{x2, y2}, _c2} ->
                 y1 < y2 || (y1 == y2 && x1 < x2)
               end)
               |> Enum.map(fn {_coord, c} -> c end)
               |> Enum.join()}
            end)
          end)

        {id, borders_only}
      end)

    borders_only
    |> Enum.map(fn {id, variations} ->
      rr =
        variations
        |> Enum.with_index()
        |> Enum.map(fn {variation, index} ->
          r =
            borders_only
            |> Enum.filter(fn {id2, _v} -> id != id2 end)
            |> Enum.map(fn {id2, tiles} ->
              rrr =
                tiles
                |> Enum.with_index()
                |> Enum.map(fn {tile, i} ->
                  res = %{
                    :right => tile[:left] == variation[:right],
                    :left => tile[:right] == variation[:left],
                    :top => tile[:top] == variation[:bottom],
                    :bottom => tile[:bottom] == variation[:top]
                  }

                  {@variations[i], res}
                end)

              {id2, rrr}
            end)

          {@variations[index], r}
        end)

      {id, rr}
    end)
    |> Enum.map(fn {id, variations} ->
      m =
        variations
        |> Enum.map(fn {_variation_name, options} ->
          Enum.map(options, fn {option_id, option_variations} ->
            r =
              Enum.filter(option_variations, fn {_name, map} ->
                map |> Map.values() |> Enum.member?(true)
              end)
              |> Enum.map(fn {_name, map} ->
                Map.to_list(map) |> Enum.filter(&match?({_, true}, &1))
              end)

            {option_id, r}
          end)
          |> Enum.filter(fn {_idd, v} -> v != [] end)
        end)

      {id, m}
    end)
    |> Enum.map(fn {id, m} ->
      max =
        Enum.map(m, fn borders -> Enum.count(borders) end)
        |> Enum.max()

      {id, max}
    end)
    |> Enum.filter(fn {_id, count} -> count == 2 end)
    |> Enum.map(fn {id, _count} -> id end)
    |> Enum.reduce(&(&1 * &2))
  end

  def part2() do
    variations =
      get_input()
      |> Enum.map(fn {id, tile} ->
        right_rotated = rotate_tile_right(tile)

        horizontal_mirrored = mirror_tile(tile, :horizontal, @tile_size)

        left_rotated = rotate_tile_right(horizontal_mirrored)

        vertical_mirorred = mirror_tile(tile, :vertical, @tile_size)

        variations = [
          tile,
          vertical_mirorred,
          horizontal_mirrored,
          right_rotated,
          mirror_tile(right_rotated, :horizontal, @tile_size),
          mirror_tile(left_rotated, :horizontal, @tile_size),
          left_rotated,
        ]

        {id, variations}
      end)

    borders_only =
      variations
      |> Enum.map(fn {id, variations} ->
        borders_only =
          Enum.map(variations, fn tile ->
            tile
            |> Map.to_list()
            |> Enum.filter(fn {{x, y}, _c} ->
              x == 0 || y == 0 || x == @tile_size || y == @tile_size
            end)
          end)
          |> Enum.reduce([], fn variation_borders, agg ->
            res =
              Map.put(%{}, :top, variation_borders |> Enum.filter(fn {{_x, y}, _c} -> y == 0 end))
              |> Map.put(:left, variation_borders |> Enum.filter(fn {{x, _y}, _c} -> x == 0 end))
              |> Map.put(
                :right,
                variation_borders |> Enum.filter(fn {{x, _y}, _c} -> x == @tile_size end)
              )
              |> Map.put(
                :bottom,
                variation_borders |> Enum.filter(fn {{_x, y}, _c} -> y == @tile_size end)
              )

            [res | agg]
          end)
          |> Enum.map(fn map ->
            map
            |> Map.to_list()
            |> Enum.map(fn {place, row} ->
              {place,
               row
               |> Enum.sort(fn {{x1, y1}, _c1}, {{x2, y2}, _c2} ->
                 y1 < y2 || (y1 == y2 && x1 < x2)
               end)
               |> Enum.map(fn {_coord, c} -> c end)
               |> Enum.join()}
            end)
            |> Enum.reduce(%{}, fn {place, row}, m ->
              Map.put(m, place, row)
            end)
          end)

        {id, borders_only}
      end)
      |> Enum.map(fn {id, variations} ->
        {id,
         variations
         |> Enum.with_index()
         |> Enum.reduce(%{}, fn {var, i}, m -> Map.put(m, @variations[i], var) end)}
      end)

    maps =
      borders_only
      |> Enum.map(&find_matches(&1, borders_only))
      |> build_map({0, 0})

    maps
    |> Enum.map(fn m ->
      m
      |> Map.to_list()
      |> Enum.map(fn {coords, {id, name}} ->
        tilev =
          Enum.find_value(variations, fn {idd, v} ->
            if idd == id do
              v
            else
              false
            end
          end)
          |> Enum.with_index()
          |> Enum.map(fn {v, i} -> %{@variations2[i] => v} end)
          |> Enum.reduce(&Map.merge(&1, &2))

          trimmed = tilev[name]
          |> Map.to_list()
          |> Enum.filter(fn {{x, y}, _} -> x != 0 && y != 0 && y != @tile_size && x != @tile_size end)
          |> Enum.reduce(%{}, fn {k, v}, m -> Map.put(m, k, v) end)

        {coords, trimmed}
      end)
    end)
    |> Enum.map(fn map ->
      map
      |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} -> y1 > y2 || (y1 == y2  && x1 < x2) end)
      |> Enum.chunk_every(3)
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn {_, r} ->
          Map.to_list(r)
        end)
        |> Enum.map(fn row ->
          row
          |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} -> y1 > y2 || (y1 == y2 && x1 < x2) end)
          |> Enum.group_by(fn {{x, y}, _} -> y end)
          |> Enum.reduce(%{1 => "", 2 => "", 3 => "", 4 => "", 5 => "", 6 => "", 7 => "", 8 => ""}, fn {y, chars}, m ->
            Enum.reduce(chars, m, fn {{x, y}, c}, m2 -> Map.put(m2, y, m2[y] <> c) end)
          end)
        end)
        |> Enum.reduce(%{1 => "", 2 => "", 3 => "", 4 => "", 5 => "", 6 => "", 7 => "", 8 => ""}, fn m2, m ->
          m
          |> Map.keys()
          |> Enum.reduce(m, fn k, m3 ->
            Map.put(m3, k, m3[k] <> m2[k])
          end)
        end)
      end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {g, i}, m ->
        g
        |> Map.keys()
        |> Enum.reduce(m, fn k, m2 ->
          Map.put(m2, i * 10 + k, g[k])
        end)
      end)
    end)
    |> Enum.map(fn image ->
      image
      |> Map.to_list()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {{_, row}, y}, m ->
        row
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce(m, fn {c, x}, m2 -> Map.put(m2, {x, y}, c) end)
      end)
    end)
    |> Enum.map(fn tile ->
        right_rotated = rotate_tile_right(tile)

        horizontal_mirrored = mirror_tile(tile, :horizontal, 3 * 8)

        left_rotated = rotate_tile_right(horizontal_mirrored)

        vertical_mirorred = mirror_tile(tile, :vertical, 3 * 8)

        variations = [
          tile,
          vertical_mirorred,
          horizontal_mirrored,
          right_rotated,
          mirror_tile(right_rotated, :horizontal, 3 * 8),
          mirror_tile(left_rotated, :horizontal, 3 * 8),
          left_rotated,
        ]
    end)
    |> Enum.uniq()
  end

  defp build_map([{head_id, head_variations} | tail] = tiles, {x, y}) do
    head_variations
    |> Map.to_list()
    |> Enum.map(fn {first_name, adjacents} ->

      start = %{
        {x, y} => {head_id, first_name}
      }

      Enum.reduce(adjacents, {start, {0, 0}}, fn {other_id, [{other_name, side}]},
                                                 {map, {x, y}} ->
        m =
          case side do
            :left -> Map.put(map, {x - 1, y}, {other_id, other_name})
            :right -> Map.put(map, {x + 1, y}, {other_id, other_name})
            :top -> Map.put(map, {x, y + 1}, {other_id, other_name})
            :bottom -> Map.put(map, {x, y - 1}, {other_id, other_name})
          end

        {m, {x, y}}
      end)
      |> case do
        {m, _} -> m
      end
    end)
    |> Enum.flat_map(fn m ->
      place_next_tiles(m, tiles)
    end)
    |> keep_going(tiles)
    |> Enum.uniq()
  end


  defp keep_going(maps, tiles) do
    Enum.flat_map(maps, fn map ->
      if map |> Map.keys() |> Enum.count() == Enum.count(tiles) do
        [map]
      else
        place_next_tiles(map, tiles)
        |> keep_going(tiles)
      end
    end)
  end

  defp place_next_tiles(map, tiles) do
    new_maps =
      map
      |> Map.to_list()
      |> Enum.map(fn {{x, y}, {id, name}} ->
        current =
          Enum.find_value(tiles, fn {idd, variations} ->
            if idd == id do
              Enum.find_value(variations, fn {namee, adjacents} ->
                if namee == name do
                  adjacents
                else
                  false
                end
              end)
            else
              false
            end
          end)

        {id, name, {x, y}, current}
      end)
      |> Enum.map(fn {id, name, {x, y}, adj} = p ->
        if adj == nil do
          %{:error => :yes}
        else
          Enum.reduce(adj, map, fn {idd, [{namee, pos}]}, m ->
            check_coord = %{
              :right => {x + 1, y},
              :left => {x - 1, y},
              :bottom => {x, y - 1},
              :top => {x, y + 1}
            }

            c = check_coord[pos]

            if m[c] == nil do
              already_there =
                m
                |> Map.values()
                |> Enum.map(fn
                  {x, _} -> x
                  _ -> idd
                end)
                |> Enum.member?(idd)

              if already_there do
                %{:error => :yes}
              else
                Map.put(m, c, {idd, namee})
              end
            else
              if m[c] == {idd, namee} do
                m
              else
                %{:error => :yes}
              end
            end
          end)
        end
      end)
      |> Enum.filter(fn map -> !Map.has_key?(map, :error) end)

    tiles_count = Enum.count(tiles)

    Enum.filter(new_maps, fn nm -> nm != map || (nm == map && Map.keys(map) == 9) end)
  end

  defp find_matches({id, variations}, others) do
    other_tiles = Enum.filter(others, fn {idd, _} -> id != idd end)

    k =
      variations
      |> Map.to_list()
      |> Enum.map(fn {name, borders} ->
        options =
          Enum.map(other_tiles, fn {other_id, other_variations} ->
            var_matches =
              other_variations
              |> Map.to_list()
              |> Enum.map(fn {other_name, other_borders} ->
                matches =
                  case {borders[:bottom] == other_borders[:top],
                        borders[:right] == other_borders[:left],
                        borders[:left] == other_borders[:right],
                        borders[:top] == other_borders[:bottom]} do
                    {true, false, false, false} -> :bottom
                    {false, true, false, false} -> :right
                    {false, false, true, false} -> :left
                    {false, false, false, true} -> :top
                    _ -> nil
                  end

                {other_name, matches}
              end)
              |> Enum.filter(fn {_other_name, matches} -> matches != nil end)

            {other_id, var_matches}
          end)
          |> case do
               m ->
                 m
             end
          |> Enum.filter(fn {_other_id, var_matches} -> var_matches != [] end)

        {name, options}
      end)

    k_max = k |> Enum.map(fn {_name, matches} -> Enum.count(matches) end) |> Enum.max()

    k
    |> Enum.filter(fn {name, matches} -> Enum.count(matches) == k_max end)
    |> Enum.reduce(%{}, fn {name, matches}, m -> Map.put(m, name, matches) end)
    |> case do
      m -> {id, m}
    end
  end

  defp rotate_tile_right(tile, size \\ @tile_size) do
    tile
    |> Map.to_list()
    |> Enum.map(fn {{x, y}, c} -> {{size - y, x}, c} end)
    |> Enum.reduce(%{}, fn {coords, c}, m -> Map.put(m, coords, c) end)
  end

  defp mirror_tile(tile, :vertical, size) do
    tile
    |> Map.to_list()
    |> Enum.map(fn {{x, y}, c} -> {{x, size - y}, c} end)
    |> Enum.reduce(%{}, fn {coords, c}, m -> Map.put(m, coords, c) end)
  end

  defp mirror_tile(tile, :horizontal, size) do
    tile
    |> Map.to_list()
    |> Enum.map(fn {{x, y}, c} -> {{size - x, y}, c} end)
    |> Enum.reduce(%{}, fn {coords, c}, m -> Map.put(m, coords, c) end)
  end

  defp draw_tile(tile) do
    tile
    |> Map.to_list()
    |> Enum.sort(fn {{x1, y1}, _c1}, {{x2, y2}, _c2} -> y1 < y2 || (y1 == y2 && x1 < x2) end)
    |> Enum.reduce({"", 0}, fn
      {{_, y}, c}, {line, y} ->
        {line <> c, y}

      {{_, y}, c}, {line, _row} ->
        {c, y}
    end)
    |> case do
      {last_line, _y} -> IO.inspect(last_line)
    end

    :ok
  end

  defp get_input() do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(fn ["Tile " <> tile_id | rows] ->
      id = tile_id |> String.replace(":", "") |> String.to_integer()

      tile =
        rows
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {row, y}, m ->
          row
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.reduce(m, fn {c, x}, m -> Map.put(m, {x, y}, c) end)
        end)

      {id, tile}
    end)
    |> Enum.to_list()
  end
end
