defmodule NightGame.WorldTest do
  use ExUnit.Case

  doctest NightGame.World

  test "random_position" do
    :rand.seed({:exsss, [27_915_312_798_172_385 | 38_394_368_618_753_574]})
    assert NightGame.World.random_position(NightGame.World.map()) == {13, 24}
  end
end
