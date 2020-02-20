defmodule NightGame.GameTest do
  use ExUnit.Case, async: false

  alias NightGame.{
    Game,
    World
  }

  doctest NightGame.Game

  setup do
    Game.restart()
  end

  test "spawn new hero" do
    hero = Game.get_or_spawn_hero("test")
    assert hero.dead? == false
  end

  test "spawn new hero and get once again" do
    hero1 = Game.get_or_spawn_hero("test")
    hero2 = Game.get_or_spawn_hero("test")
    assert hero1 == hero2
  end

  test "hero is on the map" do
    Game.get_or_spawn_hero("test", {3, 3})
    assert World.get(Game.map(), 3, 3) == {:heroes, [{"test", false}]}
  end

  test "hero can move left" do
    Game.get_or_spawn_hero("test", {3, 3})
    Game.move_hero("test", :left)
    assert World.get(Game.map(), 2, 3) == {:heroes, [{"test", false}]}
  end

  test "hero will kill" do
    Game.get_or_spawn_hero("test1", {3, 3})
    Game.get_or_spawn_hero("test2", {3, 4})
    Game.attack("test1")
    assert World.get(Game.map(), 3, 4) == {:heroes, [{"test2", true}]}
  end

  test "hero will kill and respawn after 5 seconds" do
    Game.get_or_spawn_hero("test1", {3, 3})
    Game.get_or_spawn_hero("test2", {3, 4})
    Game.attack("test1")
    assert World.get(Game.map(), 3, 4) == {:heroes, [{"test2", true}]}
    Process.sleep(6000)
    %{x: x, y: y} = Game.get_or_spawn_hero("test2")
    assert World.get(Game.map(), x, y) == {:heroes, [{"test2", false}]}
  end
end
