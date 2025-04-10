defmodule LuexTableArrayTest do
  use ExUnit.Case
  alias Luex.Table
  alias Luex.Table.Array
  doctest Array
  require Luex

  describe "append/3" do
    # TODO add test against malformed array
    # reminder: happy path test is module doc

    test "append to non array" do
      {[no_array], vm} =
        Luex.init()
        |> Luex.do_inline("""
        return { a = 123; b = 567; };
        """)

      match_msg = ~r/lua table is not a well formed array, because of key .* #{inspect(no_array)}/

      assert_raise Table.NotAnArrayException, match_msg, fn ->
        Array.append(vm, no_array, "value")
      end
    end
  end
end
