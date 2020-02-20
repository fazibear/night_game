defmodule NightGameWeb.Game do
  @moduledoc """
  Display game map
  """

  use Phoenix.LiveView
  alias NightGame.Game

  @impl true
  def render(assigns) do
    ~L"""
    <h1>
      You're playing <%= @name %>
      <%= if Map.get(@info, :dead, false) do %>
        (DEAD)
      <% end %>
    </h1>
    <div class="map" phx-window-keydown="key">
      <%= for row <- Tuple.to_list(@map) do %>
        <div class="row">
        <%= for tile <- Tuple.to_list(row) do %>
          <%= case tile do %>
            <% {:heroes, heroes} -> %>
              <div class="grid heroes">
                <%= for {name, dead} <- heroes do %>
                  <div class="hero <%= if dead, do: "dead", else: "" %> <%= if @name == name, do: "my", else: "" %>">
                    <div class="name">
                      <%= name %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% {_, tile} -> %>
              <div class="grid tile-<%= tile %>"></div>
            <% _ -> %><div class="grid"></div>
          <% end %>
        <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"name" => name}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(NightGame.PubSub, "game")
    end

    socket =
      socket
      |> put_map()
      |> put_name(name)
      |> put_info(%{})

    refresh()

    {:ok, socket}
  end

  @impl true
  def handle_event("key", %{"code" => "ArrowLeft"}, socket) do
    Game.move_hero(socket.assigns.name, :left)
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", %{"code" => "ArrowRight"}, socket) do
    Game.move_hero(socket.assigns.name, :right)
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", %{"code" => "ArrowUp"}, socket) do
    Game.move_hero(socket.assigns.name, :up)
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", %{"code" => "ArrowDown"}, socket) do
    Game.move_hero(socket.assigns.name, :down)
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", %{"code" => "Space"}, socket) do
    Game.attack(socket.assigns.name)
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", _, socket) do
    refresh()
    {:noreply, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    socket =
      socket
      |> put_map()
      |> put_info(Game.get_or_spawn_hero(socket.assigns.name))

    {:noreply, socket}
  end

  def refresh() do
    Phoenix.PubSub.broadcast(NightGame.PubSub, "game", :refresh)
  end

  defp put_map(socket) do
    assign(socket, map: Game.map())
  end

  defp put_name(socket, name) do
    assign(socket, name: name)
  end

  defp put_info(socket, info) do
    assign(socket, info: info)
  end
end
