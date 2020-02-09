defmodule NightGame.Hero do
  @moduledoc """
  Character controlled by player
  """

  use GenServer
  alias NightGame.World

  defstruct [:position, :dead]

  @exit_timeout 5000

  @doc """
  Start Hero gem_server.
  Parameters:
    position: position
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Get info of the hero.

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(%{position: 31})
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead: false, position: 31}
  """
  def info(pid) do
    GenServer.call(pid, :info)
  end

  @doc """
  Move the hero.
  Directions:
   - :up
   - :down
   - :left
   - :right

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(%{position: 65})
    iex> NightGame.Hero.move(pid, :left)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead: false, position: 64}

    iex> {:ok, pid} = NightGame.Hero.start_link(%{position: 65})
    iex> NightGame.Hero.move(pid, :up)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead: false, position: 35}

  """
  def move(pid, direction) do
    GenServer.cast(pid, {:move, direction})
  end

  @doc """
  Kill the hero on specifix position.

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(%{position: 65})
    iex> NightGame.Hero.kill(pid, 65)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead: true, position: 65}
  """
  def kill(pid, position) do
    GenServer.cast(pid, {:kill, position})
  end

  @doc """
  Returns positions to attack by hero.

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(%{position: 65})
    iex> NightGame.Hero.attack(pid)
    [65, 66, 64, 95, 35, 96, 36, 94, 34]
  """
  def attack(pid) do
    GenServer.call(pid, :attack)
  end

  # Callbacks

  @impl true
  def init(%{position: position}) do
    {:ok,
     %__MODULE__{
       position: position,
       dead: false
     }}
  end

  @impl true
  def handle_info(:exit, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:attack, _from, %{dead: false} = state) do
    {:reply, World.attack_positions(state.position), state}
  end

  @impl true
  def handle_call(:attack, _from, state), do: {:reply, [], state}

  @impl true
  def handle_cast({:move, direction}, %{dead: false} = state) do
    {:noreply, %{state | position: World.move(direction, state.position)}}
  end

  @impl true
  def handle_cast({:move, _}, state), do: {:noreply, state}

  @impl true
  def handle_cast({:kill, position}, %{dead: false} = state) do
    if position == state.position do
      Process.send_after(self(), :exit, @exit_timeout)
      {:noreply, %{state | dead: true}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:kill, _}, state), do: {:noreply, state}
end
