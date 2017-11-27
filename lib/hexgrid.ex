defmodule Hexgrid do
  require Logger
  alias Hexgrid.Hexagon
  alias Hexgrid.Offset

  @moduledoc """
  Hexgrid utilities
  """

  @doc ~S"""
  Returns a MapSet containing grid of `row` rows and `col` columns of Hexagons.
  Top left corner of the grid is at %Hexagon{q: 0, r: 0, s: 0}
  """
  def create(row, col) do
    create(MapSet.new, row, col)
  end

  @doc ~S"""
  Logs visualization of `mapset` using cube coordinates to console with logger level info.
  """
  def draw_cube(%MapSet{} = mapset) do
    max_row = Enum.max_by(mapset, fn(h) -> h.r end).r
    min_row = Enum.min_by(mapset, fn(h) -> h.r end).r

    rows = Enum.map(min_row..max_row, fn(row) -> filter_by_row(mapset, row) end)

    formatted_rows = Enum.map(rows, fn(row) -> draw_hexagon_row(row, min_row, max_row) end)

    Logger.info ["\n" | formatted_rows]
  end

  @doc ~S"""
  Logs visualization of `mapset` using offset coordinates to console with logger level info.
  """
  def draw_offset(%MapSet{} = mapset) do
    max_row = Enum.max_by(mapset, fn(h) -> h.r end).r
    min_row = Enum.min_by(mapset, fn(h) -> h.r end).r

    rows = Enum.map(min_row..max_row, fn(row) -> filter_by_row(mapset, row) end)

    formatted_rows = Enum.map(rows, fn(row) -> draw_hexagon_row(
      Enum.map(row, fn(h) -> Offset.roffset_from_cube(0, h) end), min_row, max_row) end)

    Logger.info ["\n" | formatted_rows]
  end

  defp create(mapset, row, _col) when row < 0 do
    mapset
  end

  defp create(mapset, row, col) do
    mapset = create_row(mapset, row, col)
    create(mapset, row - 1, col)
  end

  defp create_row(mapset, _row, col) when col < 0 do
    mapset
  end

  defp create_row(mapset, row, col) do
    hexagon = Offset.roffset_to_cube(0, %Offset{col: col, row: row})

    mapset
    |> MapSet.put(hexagon)
    |> create_row(row, col - 1)
  end

  defp offset_hexagon_partial(i, type) when i == 0 do
    case type do
      :top           -> "   .^.   "
      :top_coords    -> ".´     `."
      :middle        -> "|<%= col %> <%= row %>|"
      :bottom_coords -> "^.     .^"
      :bottom        -> "   `.´   "
    end
  end

  defp offset_hexagon_partial(_, type) do
    case type do
      :top           -> "  .^.   "
      :top_coords    -> "´     `."
      :middle        -> "<%= col %> <%= row %>|"
      :bottom_coords -> ".     .^"
      :bottom        -> "  `.´   "
    end
  end

  defp cube_hexagon_partial(i, type) when i == 0 do
    case type do
      :top           -> "   .^.   "
      :top_coords    -> ".´<%= r %> <%= q %>`."
      :middle        -> "|       |"
      :bottom_coords -> "^. <%= s %> .^"
      :bottom        -> "   `.´   "
    end
  end

  defp cube_hexagon_partial(_, type) do
    case type do
      :top           -> "  .^.   "
      :top_coords    -> "´<%= r %> <%= q %>`."
      :middle        -> "       |"
      :bottom_coords -> ". <%= s %> .^"
      :bottom        -> "  `.´   "
    end
  end

  defp draw_hexagon_row_partial(%Offset{} = h, i, type) do
    partial = offset_hexagon_partial(i, type)

    case type do
      :middle -> partial
        |> EEx.eval_string([
          col: h.col |> Integer.to_string |> String.pad_leading(3),
          row: h.row |> Integer.to_string |> String.pad_trailing(3)
        ])
      _default -> partial
    end
  end

  defp draw_hexagon_row_partial(%Hexagon{} = h, i, type) do
    partial = cube_hexagon_partial(i, type)

    case type do
      :top_coords -> partial
        |> EEx.eval_string([
          r: h.r |> Integer.to_string |> String.pad_trailing(2),
          q: h.q |> Integer.to_string |> String.pad_leading(2)
        ])
      :bottom_coords -> partial
        |> EEx.eval_string([
          s: h.s |> Integer.to_string |> String.pad_leading(3)
        ])
      _default -> partial
    end
  end

  defp is_first_row([%Hexagon{} = head | _], min_row) do
    head.r == min_row
  end

  defp is_first_row([%Offset{} = head | _], min_row) do
    head.row == min_row
  end

  defp is_last_row([%Hexagon{} = head | _], max_row) do
    head.r == max_row
  end

  defp is_last_row([%Offset{} = head | _], max_row) do
    head.row == max_row
  end

  defp offset_whitespace([%Hexagon{} = head | _], min_row) do
    String.duplicate("    ", head.r - min_row)
  end

  defp offset_whitespace([%Offset{} = head | _], min_row) do
    String.duplicate("    ", head.row - min_row)
  end

  defp maybe_draw_top(result, row, whitespace, min_row) do
    if is_first_row(row, min_row) do
      result |> draw_section(row, whitespace, :top)
    else
      result
    end
  end

  defp maybe_draw_bottom(result, row, whitespace, max_row) do
    if is_last_row(row, max_row) do
      result |> draw_section(row, whitespace, :bottom)
    else
      result
    end
  end

  defp draw_section(result, row, whitespace, type) do
    result ++
    [whitespace |
      row
      |> Enum.with_index
      |> Enum.map(fn({v, k}) -> draw_hexagon_row_partial(v, k, type) end)
      |> Kernel.++(["\n"])]
  end

  defp draw_hexagon_row(row, min_row, max_row) do
    whitespace = offset_whitespace(row, min_row)

    maybe_draw_top([], row, whitespace, min_row)
    |> draw_section(row, whitespace, :top_coords)
    |> draw_section(row, whitespace, :middle)
    |> draw_section(row, whitespace, :bottom_coords)
    |> maybe_draw_bottom(row, whitespace, max_row)
    |> Enum.join()
  end

  defp filter_by_row(%MapSet{} = mapset, row) do
    mapset
    |> Enum.filter(fn(h) -> h.r == row end)
    |> Enum.sort(fn(a, b) -> a.q <= b.q end)
  end
end
