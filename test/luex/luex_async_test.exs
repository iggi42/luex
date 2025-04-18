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

  
end
