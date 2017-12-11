defmodule HextilleTest do
  use ExUnit.Case

  alias Hextille.Cube, as: Cube
  alias Hextille.Offset, as: Offset
  alias Hextille.HexGrid, as: HexGrid

  doctest Cube
  doctest Offset
  doctest HexGrid
end
