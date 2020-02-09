defmodule NightGame.WorldTest do
  use ExUnit.Case

  alias NightGame.World
  doctest NightGame.World

  test "random position" do
    assert World.random_position() != World.random_position()
  end

  test "put_hero" do
    map = World.put_hero(World.tiles(), 31, "my_hero", false)

    assert Enum.at(map, 31) == {:hero, "my_hero", false}
  end
end
