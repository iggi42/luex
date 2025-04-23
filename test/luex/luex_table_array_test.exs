defmodule LuexTableArrayTest do
  use ExUnit.Case
  alias Luex.Table
  alias Luex.Table.Array
  doctest Array
  require Luex
  alias Luex.CallResult, as: LCall

  describe "append/3" do
    # TODO add test against malformed array
    # reminder: happy path test is module doc

    test "append to non array" do
      %Luex.CallResult{return: [no_array], vm: vm} =
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

  describe "fold/4" do
    # TODO test against arrays with missing keys (like only with keys 1, 2, 4, 5 present)
  end

  describe "new/2" do
    test "create simple new array (happy path)" do
      %LCall{return: array, vm: vm} = Luex.init() |> Luex.Table.Array.new(["a", "b", "c"])
      assert %{1 => "a", 2 => "b", 3 => "c"} == Luex.Table.get_data(vm, array)
    end
  end
end
