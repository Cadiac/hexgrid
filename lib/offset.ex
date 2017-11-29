defmodule Hexgrid.Offset do
  alias Hexgrid.Offset, as: Offset
  alias Hexgrid.Hexagon
  use Bitwise

  @moduledoc """
  Hexagon module that represents Hexagon tiles using offset coordinates.
  Instead of names x, y this module uses names col and row.

  Coordinates in q-offset system represent hexagons in pointy top orientation,
  r-offset in flat top orientation.

  This module should only be used to display coordinates as offset coordinates.
  All math should be done by using cube coordinates.
  ```
  """

  defstruct col: 0, row: 0

  @doc """
  Converts Hexagon in cube coordinates to pointy top r-offset coordinates.

  ## Examples:
    iex> h = %Hexagon{q: 4, r: 3, s: -7}
    iex> Offset.roffset_from_cube(0, h)
    %Offset{col: 5, row: 3}
    iex> Offset.roffset_from_cube(1, h)
    %Offset{col: 6, row: 3}
  """
  def roffset_from_cube(offset, %Hexagon{} = h) do
    col = h.q + div((h.r + offset * (h.r &&& 1)), 2)
    row = h.r

    %Offset{col: col, row: row}
  end

  @doc """
  Converts Offset in pointy top r-offset coordinates to Hexagon.

  TODO: THIS SHOULD BE CALLED soffset! S is the "row"

  ## Examples:
    iex> a = %Offset{col: 5, row: 3}
    iex> b = %Offset{col: 6, row: 3}
    iex> Offset.roffset_to_cube(0, a)
    %Hexagon{q: 4, r: 3, s: -7}
    iex> Offset.roffset_to_cube(1, b)
    %Hexagon{q: 4, r: 3, s: -7}
  """
  def roffset_to_cube(offset, %Offset{} = h) do
    q = h.col - div((h.row + offset * (h.row &&& 1)), 2)
    r = h.row
    s = -q - r

    %Hexagon{q: q, r: r, s: s}
  end

  @doc """
  Converts Hexagon in cube coordinates to flat top q-offset coordinates.

  ## Examples:
    iex> h = %Hexagon{q: 3, r: 4, s: -7}
    iex> Offset.qoffset_from_cube(0, h)
    %Offset{col: 3, row: 5}
    iex> Offset.qoffset_from_cube(1, h)
    %Offset{col: 3, row: 6}
  """
  def qoffset_from_cube(offset, %Hexagon{} = h) do
    col = h.q
    row = h.r + div((h.q + offset * (h.q &&& 1)), 2)

    %Offset{col: col, row: row}
  end

  @doc """
  Converts Offset in flat top q-offset coordinates to Hexagon.

  ## Examples:
    iex> a = %Offset{col: 3, row: 5}
    iex> b = %Offset{col: 3, row: 6}
    iex> Offset.qoffset_to_cube(0, a)
    %Hexagon{q: 3, r: 4, s: -7}
    iex> Offset.qoffset_to_cube(1, b)
    %Hexagon{q: 3, r: 4, s: -7}
  """
  def qoffset_to_cube(offset, %Offset{} = h) do
    q = h.col;
    r = h.row - div((h.col + offset * (h.col &&& 1)), 2)
    s = -q - r

    %Hexagon{q: q, r: r, s: s}
  end
end
