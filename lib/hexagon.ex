defmodule Hexagon do
  @moduledoc """
  Hexagon module that represents Hexagon tiles using cube coordinates.
  Instead of names x, y, z this module uses names q, r, s.

  Axes are aligned as follows:
  ```
             -s
             .^.
          .´     `.
    +r .´           `. +q
      |               |
      .               .
      |               |
    -q `.           .´ -r
          `.     .´
             `.´
             +s

  ```
  """

  defstruct q: 0, r: 0, s: 0

  @doc """
  Addition of cube coordinates.
  Returns a new Hexagon with added coordinates.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> b = %Hexagon{q: 3, r: 2, s: 1}
    iex> Hexagon.add(a, b)
    %Hexagon{q: 4, r: 4, s: 4}
  """
  def add(%Hexagon{} = a, %Hexagon{} = b) do
    %Hexagon{
      q: a.q + b.q,
      r: a.r + b.r,
      s: a.s + b.s
    }
  end

  @doc """
  Subtraction of cube coordinates.
  Returns a new subtracted Hexagon.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> b = %Hexagon{q: 3, r: 2, s: 1}
    iex> Hexagon.subtract(a, b)
    %Hexagon{q: -2, r: 0, s: 2}
  """
  def subtract(%Hexagon{} = a, %Hexagon{} = b) do
    %Hexagon{
      q: a.q - b.q,
      r: a.r - b.r,
      s: a.s - b.s
    }
  end


  @doc """
  Scale cube coordinates with given multiplier `k`.
  Returns a new scaled Hexagon.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> Hexagon.scale(a, 3)
    %Hexagon{q: 3, r: 6, s: 9}
  """
  def scale(%Hexagon{} = a, k) when is_integer(k) do
    %Hexagon{
      q: a.q * k,
      r: a.r * k,
      s: a.s * k
    }
  end

  @doc ~S"""
  Rotate cube coordinates 60° to given direction `:left` or `:right`.
  Returns a new Hexagon at rotated position.

  Rotations visualized
  ```

           .^.     .^.     .^.
        .´2   0`.´     `.´0   2`.
        |       |       |       |
       .^. -2  .^.     .^. -2  .^.
    .´     `.´     `.´     `.´     `.
    |       |       |       |       |
    `.     .^.     .^.     .^.     .^.
       `.´     `.´r   q`.´     `.´-2  2`.
        |       |       |       |       |
        `.     .^.  s  .^.     .^.  0  .´
           `.´     `.´     `.´     `.´
            |       |       |       |
            `.     .^.     .^.     .´
               `.´     `.´     `.´

  ```

  ## Examples:
    iex> a = %Hexagon{q: 2, r: 0, s: -2}
    iex> Hexagon.rotate(a, :left)
    %Hexagon{q: 0, r: 2, s: -2}
    iex> Hexagon.rotate(a, :right)
    %Hexagon{q: 2, r: -2, s: 0}
  """
  def rotate(%Hexagon{} = a, direction) do
    case direction do
      :left -> %Hexagon{q: -a.r, r: -a.s, s: -a.q}
      :right -> %Hexagon{q: -a.s, r: -a.q, s: -a.r}
    end
  end

  @doc ~S"""
  Returns a new Hexagon representing the `direction` as a vector.

  Directions are enumerated in following order:
  ```

  :north_west        :north_east
               .^.
            .´r   q`.
    :west   |       |  :east
            `.  s  .´
               `.´
  :south_west        :south_east

  ```

  ## Examples:
    iex> Hexagon.directions(:north_east)
    %Hexagon{q: 1, r: 0, s: -1}
    iex> Hexagon.directions(:east)
    %Hexagon{q: 1, r: -1, s: 0}
    iex> Hexagon.directions(:south_east)
    %Hexagon{q: 0, r: -1, s: 1}
    iex> Hexagon.directions(:south_west)
    %Hexagon{q: -1, r: 0, s: 1}
    iex> Hexagon.directions(:west)
    %Hexagon{q: -1, r: 1, s: 0}
    iex> Hexagon.directions(:north_west)
    %Hexagon{q: 0, r: 1, s: -1}
  """
  def directions(direction) do
    case direction do
      :north_east -> %Hexagon{q: 1, r: 0, s: -1}
      :east -> %Hexagon{q: 1, r: -1, s: 0}
      :south_east -> %Hexagon{q: 0, r: -1, s: 1}
      :south_west -> %Hexagon{q: -1, r: 0, s: 1}
      :west -> %Hexagon{q: -1, r: 1, s: 0}
      :north_west -> %Hexagon{q: 0, r: 1, s: -1}
    end
  end

  @doc ~S"""
  Finds the neighbouring tile of hexagon `a` at the given `direction`.
  Returns a new Hexagon representing the neighbour hexagon.

  Directions are enumerated in following order:
  ```

  :north_west        :north_east
               .^.
            .´r   q`.
    :west   |       |  :east
            `.  s  .´
               `.´
  :south_west        :south_east

  ```

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> Hexagon.neighbour(a, :south_west)
    %Hexagon{q: 0, r: 2, s: 4}
    iex> Hexagon.neighbour(a, :north_east)
    %Hexagon{q: 2, r: 2, s: 2}
  """
  def neighbour(%Hexagon{} = a, direction) do
    Hexagon.add(a, Hexagon.directions(direction))
  end

  @doc ~S"""
  Returns the distance of hexagon `a` from origo as an integer.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> Hexagon.length(a)
    3
    iex> b = %Hexagon{q: -2, r: 2, s: -3}
    iex> Hexagon.length(b)
    3
  """
  def length(%Hexagon{} = a) do
    div((abs(a.q) + abs(a.r) + abs(a.s)), 2)
  end

  @doc ~S"""
  Calculates the distance between hexagons `a` and `b`.
  Return value is an integer value.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> b = %Hexagon{q: -2, r: 2, s: -3}
    iex> Hexagon.distance(a, b)
    4
  """
  def distance(%Hexagon{} = a, %Hexagon{} = b) do
    Hexagon.length(Hexagon.subtract(a, b))
  end
end
