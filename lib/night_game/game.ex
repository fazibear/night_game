defmodule NightGame.Game do
  @moduledoc """
  The game state.
  """

  use GenServer

  alias NightGame.{
    Hero,
    World
  }

  @new_game %{heroes: %{}}

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns overall game map with all tiles and heroes.
  """
  def map do
    GenServer.call(__MODULE__, :map)
  end

  @doc """
  Get hero by name.
  If hero does not exists, spawn new one.
  """
  def get_or_spawn_hero(name, position \\ :random) do
    GenServer.call(__MODULE__, {:get_or_spawn_hero, name, position})
  end

  @doc """
  Restart game world.
  """
  def restart do
    GenServer.cast(__MODULE__, :restart)
  end

  @doc """
  Move hero. See `NightGame.world.move/2`
  """
  def move_hero(name, direction) do
    GenServer.cast(__MODULE__, {:move_hero, name, direction})
  end

  @doc """
  Perform attack of the hero. Kill nearest heroes on the map.
  """
  def attack(name) do
    GenServer.cast(__MODULE__, {:attack, name})
  end

  # Callbacks
  @impl true
  def init(_params) do
    {:ok, @new_game}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    Process.demonitor(ref)

    heroes =
      state.heroes
      |> Enum.filter(fn {_name, hero_pid} -> pid != hero_pid end)
      |> Enum.into(%{})

    {:noreply, %{state | heroes: heroes}}
  end

  @impl true
  def handle_call(:map, _from, state) do
    map =
      Enum.reduce(state.heroes, World.map(), fn {name, pid}, map ->
        case Hero.info(pid) do
          %{x: x, y: y, dead?: dead?} -> World.put_hero(map, x, y, name, dead?)
          _ -> map
        end
      end)

    {:reply, map, state}
  end

  @impl true
  def handle_call({:get_or_spawn_hero, name, position}, _from, state) do
    state =
      case state do
        %{heroes: %{^name => _pid}} ->
          state

        _ ->
          {x, y} = new_hero_position(position)

          {:ok, pid} =
            DynamicSupervisor.start_child(
              NightGame.GameSupervisor,
              {Hero, [x: x, y: y]}
            )

          Process.monitor(pid)

          put_in(state, [:heroes, name], pid)
      end

    reply =
      state.heroes
      |> Map.get(name)
      |> Hero.info()

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:move_hero, name, direction}, state) do
    case state do
      %{heroes: %{^name => pid}} ->
        Hero.move(pid, direction)

      _ ->
        :nothing
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:restart, _state) do
    {:noreply, @new_game}
  end

  @impl true
  def handle_cast({:attack, name}, state) do
    case state do
      %{heroes: %{^name => pid}} ->
        %{x: x, y: y} = Hero.info(pid)

        state.heroes
        |> Map.delete(name)
        |> Enum.each(fn {_name, enemy_pid} ->
          case Hero.info(enemy_pid) do
            %{x: enemy_x, y: enemy_y, dead?: false}
            when enemy_x in (x - 1)..(x + 1) and enemy_y in (y - 1)..(y + 1) ->
              Hero.kill(enemy_pid)

            _ ->
              :nothing
          end
        end)

      _ ->
        :nothing
    end

    {:noreply, state}
  end

  # TODO: make it random
  defp new_hero_position(:random), do: {1, 1}
  defp new_hero_position(position), do: position
end
