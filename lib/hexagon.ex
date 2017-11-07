defmodule Hexagon do
  @moduledoc """
  Hexagon module that represents Hexagon tiles using cube coordinates.
  Instead of names x, y, z this module uses names q, r, s.

  Cube coordinates have a constraint `q + r + s = 0`,
  even with floating point cube coordinates. This has to be always respected.

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
    iex> a = %Hexagon{q: 1, r: -2, s: 1}
    iex> b = %Hexagon{q: 3, r: -2, s: -1}
    iex> Hexagon.add(a, b)
    %Hexagon{q: 4, r: -4, s: 0}
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
    iex> a = %Hexagon{q: 1, r: -2, s: 1}
    iex> b = %Hexagon{q: 3, r: -2, s: -1}
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
    iex> a = %Hexagon{q: 1, r: -2, s: 1}
    iex> Hexagon.scale(a, 3)
    %Hexagon{q: 3, r: -6, s: 3}
  """
  def scale(%Hexagon{} = h, k) when is_integer(k) do
    %Hexagon{
      q: h.q * k,
      r: h.r * k,
      s: h.s * k
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
  def rotate(%Hexagon{} = h, direction) do
    case direction do
      :left -> %Hexagon{q: -h.r, r: -h.s, s: -h.q}
      :right -> %Hexagon{q: -h.s, r: -h.q, s: -h.r}
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

  Neighbours visualized
  ```

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

  ```

  ## Examples:

    iex> a = %Hexagon{q: 1, r: 0, s: -1}
    iex> Hexagon.neighbour(a, :north_east)
    %Hexagon{q: 2, r: 0, s: -2}
    iex> Hexagon.neighbour(a, :north_west)
    %Hexagon{q: 1, r: 1, s: -2}
  """
  def neighbour(%Hexagon{} = h, direction) do
    Hexagon.add(h, Hexagon.directions(direction))
  end

  @doc ~S"""
  Returns the distance of hexagon `a` from origo as an integer.

  ## Examples:

    iex> a = %Hexagon{q: 1, r: -2, s: 1}
    iex> Hexagon.length(a)
    2

    iex> b = %Hexagon{q: -2, r: -3, s: 5}
    iex> Hexagon.length(b)
    5
  """
  def length(%Hexagon{} = h) do
    div((abs(h.q) + abs(h.r) + abs(h.s)), 2)
  end

  @doc ~S"""
  Calculates the distance between hexagons `a` and `b`.
  Return value is an integer value.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: -2, s: 1}
    iex> b = %Hexagon{q: -2, r: -3, s: 5}
    iex> Hexagon.distance(a, b)
    4
  """
  def distance(%Hexagon{} = a, %Hexagon{} = b) do
    Hexagon.length(Hexagon.subtract(a, b))
  end

  @doc ~S"""
  Rounds up an hexagon with float values to integer coordinates.

  ## Examples:
    iex> a = %Hexagon{q: 1.5, r: -2.25, s: 0.75}
    iex> Hexagon.round_hex(a)
    %Hexagon{q: 1, r: -2, s: 1}

    iex> b = %Hexagon{q: 1.2, r: 2.5, s: -3.7}
    iex> Hexagon.round_hex(b)
    %Hexagon{q: 1, r: 3, s: -4}
  """
  def round_hex(%Hexagon{} = h) do
    q = round(h.q)
    r = round(h.r)
    s = round(h.s)

    q_diff = abs(q - h.q)
    r_diff = abs(r - h.r)
    s_diff = abs(s - h.s)

    cond do
      (q_diff > r_diff && q_diff > s_diff) ->
        %Hexagon{q: -r - s, r: r, s: s}
      (r_diff > s_diff) ->
        %Hexagon{q: q, r: -q - s, s: s}
      true ->
        %Hexagon{q: q, r: r, s: -q - r}
    end
  end
end
