defmodule NightGameWeb.Game do
  @moduledoc """
  Display game map
  """

  use Phoenix.LiveView
  alias NightGame.Game

  def render(assigns) do
    ~L"""
    <h1>
      <%= @name %>
      <%= if Map.get(@info, :dead, false) do %>
        IS DEAD
      <% end %>
    </h1>
    <div class="map" phx-window-keydown="key">
      <%= for tile <- @map do %>
        <%= case tile do %>
          <% {:tile, tile} -> %>
            <div class="grid tile-<%= tile %>"></div>
          <% {:hero, name, dead} -> %>
            <div class="grid hero <%= if dead, do: "dead", else: "" %>">
              <div class="name">
                <%= name %>
              </div>
            </div>
          <% _ -> %><div class="grid"></div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def mount(%{"name" => name}, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(100, self(), :tick)
    end

    socket =
      socket
      |> put_map()
      |> put_name(name)
      |> put_info(%{})

    {:ok, socket}
  end

  def handle_event("key", %{"code" => "ArrowLeft"}, socket) do
    Game.move_hero(socket.assigns.name, :left)
    {:noreply, socket}
  end

  def handle_event("key", %{"code" => "ArrowRight"}, socket) do
    Game.move_hero(socket.assigns.name, :right)
    {:noreply, socket}
  end

  def handle_event("key", %{"code" => "ArrowUp"}, socket) do
    Game.move_hero(socket.assigns.name, :up)
    {:noreply, socket}
  end

  def handle_event("key", %{"code" => "ArrowDown"}, socket) do
    Game.move_hero(socket.assigns.name, :down)
    {:noreply, socket}
  end

  def handle_event("key", %{"code" => "Space"}, socket) do
    Game.attack(socket.assigns.name)
    {:noreply, socket}
  end

  def handle_event("key", _, socket) do
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    socket =
      socket
      |> put_map()
      |> put_info(Game.get_or_spawn_hero(socket.assigns.name))

    {:noreply, socket}
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
