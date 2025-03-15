defmodule LuexTest do
  require Luex
  use ExUnit.Case
  doctest Luex

  describe "init/0" do
    test "create a new lua virtual machine" do
      assert Luex.init() |> Luex.is_vm()
    end
  end

  describe "init_sandbox/0" do
    test "create an contained lua virtual machine"
  end

  describe "set_value/3" do
  end

  describe "do_inline/2" do
    test "run some multiline code and return" do
      vm = Luex.init()

      assert {["hello", 35], vm} =
               Luex.do_inline(vm, """
                 local a = [[hello]]
                 local b = 35
                 return a, b
               """)

      assert Luex.is_vm(vm)
    end
  end
end
