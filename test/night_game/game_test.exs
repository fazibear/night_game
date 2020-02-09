defmodule NightGame.GameTest do
  use ExUnit.Case, async: false

  alias NightGame.Game
  doctest NightGame.Game

  setup do
    Game.restart()
  end

  test "spawn new hero" do
    hero = Game.get_or_spawn_hero("test")
    assert hero.dead == false
  end

  test "spawn new hero and get once again" do
    hero1 = Game.get_or_spawn_hero("test")
    hero2 = Game.get_or_spawn_hero("test")
    assert hero1 == hero2
  end

  test "hero is on the map" do
    Game.get_or_spawn_hero("test", 65)
    assert Enum.at(Game.map(), 65) == {:hero, "test", false}
  end

  test "hero can move left" do
    Game.get_or_spawn_hero("test", 65)
    Game.move_hero("test", :left)
    assert Enum.at(Game.map(), 64) == {:hero, "test", false}
  end

  test "hero will kill" do
    Game.get_or_spawn_hero("test1", 65)
    Game.get_or_spawn_hero("test2", 64)
    Game.attack("test1")
    assert Enum.at(Game.map(), 64) == {:hero, "test2", true}
  end

  test "hero will kill and respawn after 5 seconds" do
    Game.get_or_spawn_hero("test1", 65)
    Game.get_or_spawn_hero("test2", 64)
    Game.attack("test1")
    assert Enum.at(Game.map(), 64) == {:hero, "test2", true}
    Process.sleep(6000)
    %{position: position} = Game.get_or_spawn_hero("test2")
    assert Enum.at(Game.map(), position) == {:hero, "test2", false}
  end
end
