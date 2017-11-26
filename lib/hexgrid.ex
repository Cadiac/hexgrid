defmodule Hexgrid do
  require Logger
  alias Hexgrid.Hexagon
  alias Hexgrid.Offset

  @moduledoc """
  Documentation for Hexgrid.
  """

  defp create_row(mapset, _r, q) when q <= 0 do
    mapset
  end

  defp create_row(mapset, r, q) do
    MapSet.put(mapset, %Hexagon{q: q, r: r, s: -q - r})
    |> create_row(r, q - 1)
  end

  def create(mapset, r, _q) when r <= 0 do
    mapset
  end

  def create(mapset, r, q) do
    mapset = create_row(mapset, r, q)
    create(mapset, r - 1, q)
  end

  def draw() do
    Logger.info "
           .^.     .^.
        .´1   1`.´0   2`.
        |       |       |
       .^. -2  .^. -2  .^.
    .´1   0`.´0   1`.´-1  2`.
    |       |       |       |
    `. -1  .^. -1  .^. -1  .´
       `.´0   0`.´-1  1`.´
        |       |       |
        `.  0  .^.  0  .´
           `.´     `.´
    "
  end

  defp hexagon_row_string(i, type) when i == 0 do
    case type do
      :top -> "   .^.   "
      :top_coords -> ".´     `."
      :middle -> "|<%= col %> <%= row %>|"
      :bottom_coords -> "^.     .^"
      :bottom -> "   `.´   "
    end
  end

  defp hexagon_row_string(_, type) do
    case type do
      :top -> "  .^.   "
      :top_coords -> "´     `."
      :middle -> "<%= col %> <%= row %>|"
      :bottom_coords -> ".     .^"
      :bottom -> "  `.´   "
    end
  end

  defp draw_hexagon_row(%Hexagon{} = h, i, type) do
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

  def draw(%MapSet{} = mapset) do
    Logger.info Enum.join([
      "\n",
      mapset
      |> Enum.with_index
      |> Enum.map(fn({v, k})
        -> draw_hexagon_row(v, k, :top) end),
      mapset
      |> Enum.with_index
      |> Enum.map(fn({v, k})
        -> draw_hexagon_row(v, k, :top_coords) end),
      mapset
      |> Enum.with_index
      |> Enum.map(fn({v, k})
        -> draw_hexagon_row(v, k, :middle) end),
      mapset
      |> Enum.with_index
      |> Enum.map(fn({v, k})
        -> draw_hexagon_row(v, k, :bottom_coords) end),
      mapset
      |> Enum.with_index
      |> Enum.map(fn({v, k})
        -> draw_hexagon_row(v, k, :bottom) end),
    ], "\n")
  end
end
