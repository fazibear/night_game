defmodule NightGame.World do
  @moduledoc """
  Shape of the world.

  World is loaded and parsed from `map.tiles` file.

  World is the list of tuples:
   - {:tile, :grass}
   - {:tile, :wall}
   - {:heroes, [{name, is_dead}]
  """

  @width 30

  @tiles __DIR__
         |> Path.join("world.map")
         |> File.read!()
         |> String.split(" ", trim: true)
         |> Enum.map(fn tile ->
           {:tile, String.trim(tile)}
         end)

  @doc """
  Returns map shape.

  This functions returns array of tuples:
    - {:tile, :wall} wall
    - {:grass} grass where hero can walk
  """
  def tiles, do: @tiles

  @doc """
  Moves hero on the map. If can't move, returns same position.
  Directions:
   - :up
   - :down
   - :left
   - :right

  ## Examples

    iex> NightGame.World.move(:left, 65)
    64

    iex> NightGame.World.move(:right, 65)
    66

    iex> NightGame.World.move(:up, 65)
    35

    iex> NightGame.World.move(:down, 65)
    95

    iex> NightGame.World.move(:up, 35)
    35

    iex> NightGame.World.move(:down, 97)
    97

    iex> NightGame.World.move(:left, 31)
    31

    iex> NightGame.World.move(:right, 59)
    59
  """
  def move(direction, position)

  def move(:up, position) do
    move_to(position, -@width)
  end

  def move(:down, position) do
    move_to(position, @width)
  end

  def move(:left, position) do
    move_to(position, -1)
  end

  def move(:right, position) do
    move_to(position, 1)
  end

  @doc """
  Returns list of positions has to be attacked.

  ## Examples

    iex> NightGame.World.attack_positions(65)
    [65, 66, 64, 95, 35, 96, 36, 94, 34]

    iex> NightGame.World.attack_positions(31)
    [31, 32, 61, 62]
  """
  def attack_positions(position) do
    [
      position,
      position + 1,
      position - 1,
      position + @width,
      position - @width,
      position + @width + 1,
      position - @width + 1,
      position + @width - 1,
      position - @width - 1
    ]
    |> Enum.filter(&can_move?/1)
  end

  @doc """
  Returns rendom valid position (on the grass)
  """
  def random_position do
    position =
      @tiles
      |> length()
      |> :rand.uniform()

    if can_move?(position) do
      position
    else
      random_position()
    end
  end

  @doc """
  Place hero on the map.

  ## Examples

    iex> NightGame.World.put_hero([{:tile, :grass}], 0, "my_hero", false)
    [{:heroes, [{"my_hero", false}]}]
  """
  def put_hero(map, position, name, is_dead?) do
    case Enum.at(map, position) do
      {:heroes, heroes} ->
        List.replace_at(map, position, {:heroes, heroes ++ [{name, is_dead?}]})

      _ ->
        List.replace_at(map, position, {:heroes, [{name, is_dead?}]})
    end
  end

  defp move_to(position, delta) do
    if can_move?(position + delta) do
      position + delta
    else
      position
    end
  end

  defp can_move?(position) do
    @tiles |> Enum.at(position) |> elem(1) == "grass"
  end
end
