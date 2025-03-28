defmodule LuexTest do
  require Luex
  use ExUnit.Case
  doctest Luex

  describe "init/0" do
    test "create a new lua virtual machine" do
      assert Luex.init() |> Luex.is_vm()
    end
  end

  describe "set_value/3" do
    test "direct global level" do
      vm0 = Luex.init()
      vm1 = Luex.set_value(vm0, ["a"], "Täääst")
      assert {["Täääst"], _vm} = Luex.do_inline(vm1, "return a")
    end

    test "happy path: a.b.c = [[Test]]" do
      vm0 = Luex.init()
      vm1 = Luex.set_value(vm0, ["a", "b", "c"], "Test")

      assert {["Test"], _vm2} = Luex.do_inline(vm1, "return a.b.c")
    end

    test "set multiple path (check no overwrite)" do
      vm = Luex.init()
        |> Luex.set_value( ["a", "b", "c"], "test1")
        |> Luex.set_value( ["a", "c"], "test2")

      assert {["test1", "test2"], _vm} = Luex.do_inline(vm, "return a.b.c, a.c")
    end
  end

  describe "get_value/2" do
    test "happy path: a.b.c = [[Test]]; return a" do
      vm0 = Luex.init()
      {_, vm1} = Luex.do_inline(vm0, "a = [[Test]]")
      assert {"Test", _vm2} = Luex.get_value(vm1, ["a"])
    end
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
