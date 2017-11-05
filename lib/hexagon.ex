defmodule Hexagon do
  @moduledoc """
  Hexagon module that represents Hexagon tiles using cube coordinates.
  Instead of names x, y, z this module uses names q, r, s.
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

  @doc """
  Rotate cube coordinates to given direction `:left` or `:right`.
  Returns a new rotated Hexagon.

  ## Examples:
    iex> a = %Hexagon{q: 1, r: 2, s: 3}
    iex> Hexagon.rotate(a, :left)
    %Hexagon{q: -3, r: -1, s: -2}
    iex> Hexagon.rotate(a, :right)
    %Hexagon{q: -2, r: -3, s: -1}
  """
  def rotate(%Hexagon{} = a, direction) do
    case direction do
      :left -> %Hexagon{q: -a.s, r: -a.q, s: -a.r}
      :right -> %Hexagon{q: -a.r, r: -a.s, s: -a.q}
    end
  end

end
