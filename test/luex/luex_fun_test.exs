defmodule LuexFunTest do
  use ExUnit.Case
  doctest Luex.Functions
  require Luex
  alias Luex.CallResult, as: LCall

  describe "new/2" do
    test "insert new a pure function and call it via lua" do
      vm = Luex.init()

      fun = fn
        [a, b], fun_vm when Luex.is_lua_number(a) and Luex.is_lua_number(b) ->
          { [a + b, a * b],  fun_vm}

        [a], fun_vm when Luex.is_lua_string(a) ->
          {["hello " <> a], fun_vm}
      end

      %LCall{return: luerl_fun, vm: vm} = Luex.Functions.new(vm, fun)
      vm = Luex.set_value(vm, ["a", "b"], luerl_fun)

      assert %LCall{return: [6, 8]} = Luex.do_inline(vm, "return a.b(4, 2)")

      assert %LCall{return: ["hello Test"]} = Luex.do_inline(vm, "return a.b([[Test]])")
    end

    test "insert new a non-pure function and call it via lua" do
      vm = Luex.init()

      fun = fn
        [a], fun_vm when Luex.is_lua_string(a) ->
          fun_vm = Luex.set_value(fun_vm, ["last_call"], a)
          {["hello " <> a], fun_vm}
      end

      %LCall{return: luerl_fun, vm: vm} = Luex.Functions.new(vm, fun)
      vm = Luex.set_value(vm, ["a", "b"], luerl_fun)

      assert %LCall{return: ["Test"]} =
               Luex.do_inline(vm, """
               a.b([[Test]])
               return last_call
               """)
    end
  end

  describe "call/3" do
    test "calling pure lua fun via elixir" do
      %LCall{vm: vm} = Luex.init() |> Luex.do_inline("""
        function c(a, b)
          return a .. " and " .. b
        end
        """)

      %LCall{return: fun, vm: vm} = Luex.get_value(vm, ["c"])
      assert %LCall{return: ["Elixir and Lua"]} = Luex.Functions.call(vm, fun, ["Elixir", "Lua"])
    end

    test "calling erl_mfa functions from luerl" do
      vm = Luex.init()
      %LCall{return: tostring, vm: vm} = Luex.get_value(vm, ["tostring"])
      assert %LCall{return: ["42"]} = Luex.Functions.call(vm, tostring, [42])
    end
  end
end
