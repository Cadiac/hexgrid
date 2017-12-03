defmodule Hexgrid do
  require Integer
  alias Hexgrid.Offset
  alias Hexgrid.Hexagon

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

  defp min_col(%MapSet{} = mapset), do: Enum.min_by(cube_to_offset_mapset(mapset), fn(x) -> x.col end).col
  defp max_col(%MapSet{} = mapset), do: Enum.max_by(cube_to_offset_mapset(mapset), fn(x) -> x.col end).col
  defp min_row(%MapSet{} = mapset), do: Enum.min_by(cube_to_offset_mapset(mapset), fn(x) -> x.row end).row
  defp max_row(%MapSet{} = mapset), do: Enum.max_by(cube_to_offset_mapset(mapset), fn(x) -> x.row end).row

  def has_neighbour(%MapSet{} = mapset, %Hexagon{} = h, direction) do
    mapset
    |> MapSet.member?(Hexagon.neighbour(h, direction))
  end

  def has_neighbour(%MapSet{} = mapset, %Hexagon{} = h) do
    %{:north_east => has_neighbour(mapset, h, :north_east),
      :east => has_neighbour(mapset, h, :east),
      :south_east => has_neighbour(mapset, h, :south_east),
      :south_west => has_neighbour(mapset, h, :south_west),
      :west => has_neighbour(mapset, h, :west),
      :north_west => has_neighbour(mapset, h, :north_west)}
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

  defp cube_to_offset_mapset(%MapSet{} = mapset) do
    Enum.map(mapset, fn(h) -> Offset.roffset_from_cube(h) end)
  end
end
