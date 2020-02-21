defmodule NightGame.Game do
  @moduledoc """
  The game state.
  """

  use GenServer

  alias NightGame.{
    Hero,
    World
  }

  @typedoc "Direction to move on the map"
  @type direction :: :left | :right | :up | :down

  @new_game %{heroes: %{}}

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns overall game map with all tiles and heroes.
  """
  @spec map() :: tuple()
  def map do
    GenServer.call(__MODULE__, :map)
  end

  @doc """
  Get hero by name.
  If hero does not exists, spawn new one.
  """
  @spec get_or_spawn_hero(String.t(), integer | :random) :: NightGame.Hero.t()
  def get_or_spawn_hero(name, position \\ :random) do
    GenServer.call(__MODULE__, {:get_or_spawn_hero, name, position})
  end

  @doc """
  Restart game world (will remove heroes from world, but don't kill genservers)
  """
  @spec restart() :: :ok
  def restart do
    GenServer.cast(__MODULE__, :restart)
  end

  @doc """
  Move hero. See `NightGame.world.move/2`
  """
  @spec move_hero(String.t(), direction) :: :ok
  def move_hero(name, direction) do
    GenServer.cast(__MODULE__, {:move_hero, name, direction})
  end

  @doc """
  Perform attack of the hero. Kill nearest heroes on the map.
  """
  @spec attack(String.t()) :: :ok
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

        _other ->
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

      _other ->
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
        attacker = Hero.info(pid)

        state.heroes
        |> Map.delete(name)
        |> Map.values()
        |> Enum.each(&try_to_kill(attacker, Hero.info(&1), &1))

      _other ->
        :nothing
    end

    {:noreply, state}
  end

  defp try_to_kill(%{x: x, y: y}, %{x: enemy_x, y: enemy_y, dead?: false}, enemy_pid)
       when enemy_x in (x - 1)..(x + 1) and enemy_y in (y - 1)..(y + 1) do
    Hero.kill(enemy_pid)
  end

  defp try_to_kill(_hero, _enemy, _enemy_pid), do: :nothing

  defp new_hero_position(:random), do: World.random_position(World.map())
  defp new_hero_position(position), do: position
end
