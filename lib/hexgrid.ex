defmodule Hexgrid do
  require Logger
  alias Hexgrid.Hexagon
  alias Hexgrid.Offset

  @moduledoc """
  Documentation for Hexgrid.
  """

  defp create_row(mapset, _row, col) when col <= 0 do
    mapset
  end

  defp create_row(mapset, row, col) do
    hexagon = Offset.roffset_to_cube(0, %Offset{col: col, row: row})

    mapset
    |> MapSet.put(hexagon)
    |> create_row(row, col - 1)
  end

  def create(mapset, row, _col) when row <= 0 do
    mapset
  end

  def create(mapset, row, col) do
    mapset = create_row(mapset, row, col)
    create(mapset, row - 1, col)
  end

  defp hexagon_row_string(i, type) when i == 0 do
    case type do
      :top           -> "   .^.   "
      :top_coords    -> ".´     `."
      :middle -> "|<%= col %> <%= row %>|"
      :bottom_coords -> "^.     .^"
      :bottom        -> "   `.´   "
    end
  end

  defp hexagon_row_string(_, type) do
    case type do
      :top           -> "  .^.   "
      :top_coords    -> "´     `."
      :middle -> "<%= col %> <%= row %>|"
      :bottom_coords -> ".     .^"
      :bottom        -> "  `.´   "
    end
  end

  defp draw_hexagon_row_partial(%Hexagon{} = h, i, type) do
    row_string = hexagon_row_string(i, type)

    case type do
      :middle -> row_string
        |> EEx.eval_string([
          col: Offset.roffset_from_cube(0, h).col |> Integer.to_string |> String.pad_leading(3),
          row: Offset.roffset_from_cube(0, h).row |> Integer.to_string |> String.pad_trailing(3)
        ])
      _default -> row_string
    end
  end

  defp is_first_row(row, min_row) do
    hd(row).r == min_row
  end

  defp offset_whitespace(row, min_row) do
    String.duplicate("    ", hd(row).r - min_row)
  end

  defp draw_hexagon_row(row, min_row, max_row) do
    whitespace = offset_whitespace(row, min_row)

    cond do
      is_first_row(row, min_row) ->
        Enum.join([
          "\n",
          row
          |> Enum.with_index
          |> Enum.map(fn({v, k})
            -> draw_hexagon_row_partial(v, k, :top) end),
          row
          |> Enum.with_index
          |> Enum.map(fn({v, k})
            -> draw_hexagon_row_partial(v, k, :top_coords) end),
          row
          |> Enum.with_index
          |> Enum.map(fn({v, k})
            -> draw_hexagon_row_partial(v, k, :middle) end),
          row
          |> Enum.with_index
          |> Enum.map(fn({v, k})
            -> draw_hexagon_row_partial(v, k, :bottom_coords) end),
          row
          |> Enum.with_index
          |> Enum.map(fn({v, k})
            -> draw_hexagon_row_partial(v, k, :bottom) end),
        ], "\n") <> "\n"
      true ->
        Enum.join([
          [whitespace |
            row
            |> Enum.with_index
            |> Enum.map(fn({v, k})
              -> draw_hexagon_row_partial(v, k, :middle) end)],
          [whitespace |
            row
            |> Enum.with_index
            |> Enum.map(fn({v, k})
              -> draw_hexagon_row_partial(v, k, :bottom_coords) end)],
          [whitespace |
            row
            |> Enum.with_index
            |> Enum.map(fn({v, k})
              -> draw_hexagon_row_partial(v, k, :bottom) end)],
        ], "\n") <> "\n"
    end
  end

  defp filter_row(%MapSet{} = mapset, row) do
    mapset
    |> Enum.filter(fn(h) -> h.r == row end)
    |> Enum.sort(fn(a, b) -> a.q <= b.q end)
  end

  def draw(%MapSet{} = mapset) do
    max_row = Enum.max_by(mapset, fn(h) -> h.r end).r
    min_row = Enum.min_by(mapset, fn(h) -> h.r end).r

    rows = Enum.map(min_row..max_row, fn(row) -> filter_row(mapset, row) end)

    Enum.map(rows, fn(row) -> draw_hexagon_row(row, min_row, max_row) end)
    |> Logger.info
  end
end
