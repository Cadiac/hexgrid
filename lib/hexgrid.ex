defmodule Hexgrid do
  require Logger
  require Integer
  alias Hexgrid.Hexagon
  alias Hexgrid.Offset
  use Bitwise

  @moduledoc """
  Hexgrid utilities
  """

  @doc ~S"""
  Returns a MapSet containing grid of `row` rows and `col` columns of Hexagons.
  Top left corner of the grid is at %Hexagon{q: 0, r: 0, s: 0}
  """
  def create(offset_col, offset_row, rows, columns) do
    create(MapSet.new, offset_col, offset_row, rows, columns)
  end

  @doc ~S"""
  Logs visualization of `mapset` using cube coordinates to console with logger level info.
  """
  def draw_cube(%MapSet{} = mapset) do
    %{:min_col => min_col,
      :min_row => min_row,
      :max_row => max_row} = boundaries(mapset)

    rows = Enum.map(min_row..max_row, fn(row) -> filter_by_row(mapset, row) end)

    formatted_rows = Enum.map(rows, fn(row) -> draw_hexagon_row(row, min_row, max_row, min_col) end)

    Logger.info ["\n" | formatted_rows]
  end

  @doc ~S"""
  Logs visualization of `mapset` using offset coordinates to console with logger level info.
  """
  def draw_offset(%MapSet{} = mapset) do
    %{:min_col => min_col,
      :min_row => min_row,
      :max_row => max_row} = boundaries(mapset)

    rows = Enum.map(min_row..max_row, fn(row) -> filter_by_row(mapset, row) end)

    formatted_rows = Enum.map(rows, fn(row) -> draw_hexagon_row(
      Enum.map(row, fn(h) -> Offset.roffset_from_cube(h) end), min_row, max_row, min_col) end)

    Logger.info ["\n" | formatted_rows]
  end

  @doc ~S"""
  Finds the Hexagons representing boundaries of a MapSet.

  iex> a = Hexgrid.create(-2, -2, 4, 4)
  iex> b = Hexgrid.create(-3, -5, 4, 4)
  iex> Hexgrid.boundaries(a)
  %{max_col: 2, max_row: 2, min_col: -2, min_row: -2}
  iex> Hexgrid.boundaries(b)
  %{max_col: 1, max_row: -1, min_col: -3, min_row: -5}
  """
  def boundaries(%MapSet{} = mapset) do
    %{:min_col => mapset |> min_col,
      :max_col => mapset |> max_col,
      :min_row => mapset |> min_row,
      :max_row => mapset |> max_row}
  end

  defp create(mapset, _offset_col, _offset_row, rows, _columns) when rows < 0 do
    mapset
  end

  defp create(mapset, offset_col, offset_row, rows, columns) do
    mapset = create_row(mapset, offset_col, offset_row, rows, columns)
    create(mapset, offset_col, offset_row, rows - 1, columns)
  end

  defp create_row(mapset, _offset_col, _offset_row, _rows, columns) when columns < 0 do
    mapset
  end

  defp create_row(mapset, offset_col, offset_row, rows, columns) do
    hexagon = Offset.roffset_to_cube(%Offset{
      col: columns + offset_col, row: rows + offset_row})

    mapset
    |> MapSet.put(hexagon)
    |> create_row(offset_col, offset_row, rows, columns - 1)
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
      :top_coords    -> ".´<%= s %> <%= q %>`."
      :middle        -> "|       |"
      :bottom_coords -> "^. <%= r %> .^"
      :bottom        -> "   `.´   "
    end
  end

  defp cube_hexagon_partial(_, type) do
    case type do
      :top           -> "  .^.   "
      :top_coords    -> "´<%= s %> <%= q %>`."
      :middle        -> "       |"
      :bottom_coords -> ". <%= r %> .^"
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
          s: h.s |> Integer.to_string |> String.pad_trailing(2),
          q: h.q |> Integer.to_string |> String.pad_leading(2)
        ])
      :bottom_coords -> partial
        |> EEx.eval_string([
          r: h.r |> Integer.to_string |> String.pad_leading(3)
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

  defp empty_columns(%Offset{} = h, min_col), do: h.col - min_col
  defp empty_columns(%Hexagon{} = h, min_col), do: Offset.roffset_from_cube(h).col - min_col

  defp offset_whitespace([head | _], min_col) do
    # Indent for 8 spaces per each empty Hexagon
    empty_cols = empty_columns(head, min_col)
    # Indent for 4 spaces on even rows
    even = (head.row + 1) &&& 1

    String.duplicate(" ", 8 * empty_cols + 4 * even)
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

  defp draw_hexagon_row(row, min_row, max_row, min_col) do
    whitespace = offset_whitespace(row, min_col)

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

  defp cube_to_offset_mapset(%MapSet{} = mapset) do
    Enum.map(mapset, fn(h) -> Offset.roffset_from_cube(h) end)
  end

  defp min_col(%MapSet{} = mapset), do: Enum.min_by(cube_to_offset_mapset(mapset), fn(x) -> x.col end).col
  defp max_col(%MapSet{} = mapset), do: Enum.max_by(cube_to_offset_mapset(mapset), fn(x) -> x.col end).col
  defp min_row(%MapSet{} = mapset), do: Enum.min_by(cube_to_offset_mapset(mapset), fn(x) -> x.row end).row
  defp max_row(%MapSet{} = mapset), do: Enum.max_by(cube_to_offset_mapset(mapset), fn(x) -> x.row end).row

end
