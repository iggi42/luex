defmodule LuexTest do
  use ExUnit.Case
  doctest Luex
  doctest Luex.Records

  test "greets the world" do
    assert Luex.hello() == :world
  end
end
