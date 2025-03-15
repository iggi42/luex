defmodule LuexLuaErrorTest do
  use ExUnit.Case

  require Luex.LuaError, as: LuaError

  describe "luerl_error/2" do
    test "match luerl lua error" do
      vm = Luex.init()

      try do
        Luerl.do(vm, "error([[error for]], [[exunit]])")
        flunk("should have caused a lua error")
      rescue
        err ->
          assert LuaError.luerl_error(reason, _vm) = err
          assert {:error_call, ["error for", "exunit"]} = reason
      end
    end
  end

  describe "wrap/1" do
  test "convert lua error to elixir exception" do
    vm = Luex.init()

    assert_raise LuaError, ~r/Lua Error: .*error for exunit.*/, fn ->
      LuaError.wrap do
        Luerl.do(vm, "error([[error for exunit]])")
      end
    end
  end
  end


  # TODO pcall test (with and without div by 0)
end
