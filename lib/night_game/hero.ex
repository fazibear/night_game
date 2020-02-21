defmodule NightGame.Hero do
  @moduledoc """
  Character controlled by player
  """

  use GenServer
  alias NightGame.World

  @typedoc "Hero representation"
  @type t :: %__MODULE__{x: integer, y: integer, dead?: boolean}

  defstruct [:x, :y, :dead?]

  @exit_timeout 5000

  @doc """
  Start Hero gem_server.
  Parameters:
    x: x
    y: y
  """
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Get info of the hero.

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(x: 11, y: 11)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead?: false, x: 11, y: 11}
  """
  @spec info(pid) :: NightGame.Hero.t()
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

    iex> {:ok, pid} = NightGame.Hero.start_link(x: 4, y: 2)
    iex> NightGame.Hero.move(pid, :left)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead?: false, x: 3, y: 2}

    iex> {:ok, pid} = NightGame.Hero.start_link(x: 4, y: 2)
    iex> NightGame.Hero.move(pid, :up)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead?: false, x: 4, y: 1}

  """
  @spec move(pid, atom) :: :ok
  def move(pid, direction) do
    GenServer.cast(pid, {:move, direction})
  end

  @doc """
  Kill the hero on specifix position.

  ## Examples

    iex> {:ok, pid} = NightGame.Hero.start_link(x: 4, y: 2)
    iex> NightGame.Hero.kill(pid)
    iex> NightGame.Hero.info(pid)
    %NightGame.Hero{dead?: true, x: 4, y: 2}
  """

  @spec kill(pid) :: :ok
  def kill(pid) do
    GenServer.cast(pid, :kill)
  end

  # Callbacks

  @impl true
  def init(x: x, y: y) do
    {:ok,
     %__MODULE__{
       x: x,
       y: y,
       dead?: false
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
  def handle_call(:attack, _from, %{dead?: false} = state) do
    {:reply, :no, state}
  end

  @impl true
  def handle_call(:attack, _from, state), do: {:reply, [], state}

  @impl true
  def handle_cast({:move, direction}, %{dead?: false} = state) do
    {new_x, new_y} =
      case direction do
        :left -> {state.x - 1, state.y}
        :right -> {state.x + 1, state.y}
        :up -> {state.x, state.y - 1}
        :down -> {state.x, state.y + 1}
        _other -> {state.x, state.y}
      end

    state =
      if World.can_move_to?(World.map(), new_x, new_y) do
        %{state | x: new_x, y: new_y}
      else
        state
      end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:move, _}, state), do: {:noreply, state}

  @impl true
  def handle_cast(:kill, %{dead?: false} = state) do
    Process.send_after(self(), :exit, @exit_timeout)
    {:noreply, %{state | dead?: true}}
  end

  @impl true
  def handle_cast(:kill, state), do: {:noreply, state}
end
