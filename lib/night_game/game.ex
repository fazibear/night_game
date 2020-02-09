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
    tiles =
      World.tiles()
      |> add_heroes(state.heroes)

    {:reply, tiles, state}
  end

  @impl true
  def handle_call({:get_or_spawn_hero, name, position}, _from, state) do
    state =
      case state do
        %{heroes: %{^name => _pid}} ->
          state

        _ ->
          {:ok, pid} =
            DynamicSupervisor.start_child(
              NightGame.GameSupervisor,
              {Hero, %{position: new_hero_position(position)}}
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
        pid
        |> Hero.attack()
        |> kill(Map.delete(state.heroes, name))

      _ ->
        :nothing
    end

    {:noreply, state}
  end

  defp add_heroes(map, heroes) do
    Enum.reduce(heroes, map, fn {name, pid}, map ->
      case Hero.info(pid) do
        %{position: position, dead: dead} -> World.put_hero(map, position, name, dead)
        _ -> map
      end
    end)
  end

  defp kill(positions, heroes) do
    heroes
    |> Map.values()
    |> Enum.map(fn pid ->
      Enum.map(positions, fn position ->
        Hero.kill(pid, position)
      end)
    end)
  end

  defp new_hero_position(:random), do: World.random_position()
  defp new_hero_position(position), do: position
end
