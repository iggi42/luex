defmodule Luex.LuexAsyncTest do
  use ExUnit.Case

  doctest Luex.Async
  doctest Luex.Async.Server

  describe "basic functionality " do
    test "start_link && do_inline" do
      assert {:ok, server} = Luex.Async.start_link([])
      assert {:ok, ["hello", "world"]} = Luex.Async.do_inline(server, """
        return "hello", "world"
        """)
    end
  end

  # inspired by https://github.com/zserge/lua-promises
  describe "test promises in lua" do
    test "promises.new" do
      setup = &Luex.configure(&1, [Luex.Async.Promises])
      {:ok, vm} = Luex.Async.start_link(setup: setup)
      Luex.Async.do_inline(vm, """
        local prom = require("promises.http")
        """)
    end
    # <promise>.then(onFullfiled, onRejected)
  end
  
end
