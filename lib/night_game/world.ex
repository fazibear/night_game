defmodule NightGame.World do
  @moduledoc """
  World is the tuple of tuples of tuples:
   - {:obstacle, :grass}
   - {:ground, :wall}
   - {:heroes, [{name, is_dead}]  G
  """

  @map Application.get_env(:night_game, :map)

  @spec map() :: tuple
  def map, do: @map

  @doc """
  Determinates when you can move to given position.

  ## Examples

    iex> NightGame.World.can_move_to?(NightGame.World.map(), 4, 2)
    true
  """
  @spec can_move_to?(tuple, integer, integer) :: boolean
  def can_move_to?(map, x, y) do
    map
    |> get(x, y)
    |> elem(0)
    |> Kernel.==(:ground)
  end

  @doc """
  Put a hero in given position on the map

  ## Examples

    iex> map = NightGame.World.put_hero(NightGame.World.map(), 3, 3, "my_hero", false)
    iex> NightGame.World.get(map, 3, 3)
    {:heroes, [{"my_hero", false}]}
  """
  @spec put_hero(tuple, integer, integer, String.t(), boolean) :: tuple | :error
  def put_hero(map, x, y, name, is_dead?) do
    case get(map, x, y) do
      {:heroes, heroes} ->
        put(map, x, y, {:heroes, [{name, is_dead?} | heroes]})

      _other ->
        put(map, x, y, {:heroes, [{name, is_dead?}]})
    end
  end

  @doc """
  Get element from given map on given position

  ## Examples

    iex> NightGame.World.get(NightGame.World.map(), 3, 3)
    {:ground, :grass}
  """
  @spec get(tuple, integer, integer) :: tuple | :error
  def get(map, x, y) do
    map
    |> elem(y)
    |> elem(x)
  rescue
    ArgumentError -> :error
  end

  @doc """
  Put given element in given position on the map

  ## Examples

    iex> map = NightGame.World.put(NightGame.World.map(), 3, 3, {:test, :something})
    iex> NightGame.World.get(map, 3, 3)
    {:test, :something}
  """
  @spec put(tuple, integer, integer, tuple) :: tuple | :error
  def put(map, x, y, tuple) do
    put_elem(
      map,
      y,
      map
      |> elem(y)
      |> put_elem(x, tuple)
    )
  rescue
    ArgumentError -> {:error, :argument_error}
  end

  @doc """
  Returns valid random position on the map.

  ## Examples

    NightGame.World.random_position(NightGame.World.map())
  """
  @spec random_position(tuple) :: {integer, integer}
  def random_position(map) do
    map
    |> Tuple.to_list()
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      row
      |> Tuple.to_list()
      |> Enum.with_index()
      |> Enum.reduce([], fn
        {{:ground, _}, x}, acc -> [{x, y} | acc]
        {_, _}, acc -> acc
      end)
      |> Kernel.++(acc)
    end)
    |> Enum.random()
  end
end
