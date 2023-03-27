defmodule LuexTest do
  use ExUnit.Case
  doctest Luex
  doctest Luex.Records

  test "greets the world" do
    vm = Luex.init()
    assert {["hello world"], _} = Luex.do_inline(vm, "return [[hello world]]")
  end
end
