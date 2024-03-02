defmodule FlyNatsExTest do
  use ExUnit.Case
  doctest FlyNatsEx

  test "greets the world" do
    assert FlyNatsEx.hello() == :world
  end
end
