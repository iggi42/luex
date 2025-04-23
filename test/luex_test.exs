defmodule LuexTest do
  require Luex
  use ExUnit.Case
  alias Luex.Call, as: LCall
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
      assert %LCall{return: ["Täääst"]} = Luex.do_inline(vm1, "return a")
    end

    test "happy path: a.b.c = [[Test]]" do
      vm0 = Luex.init()
      vm1 = Luex.set_value(vm0, ["a", "b", "c"], "Test")

      assert %LCall{return: ["Test"]} = Luex.do_inline(vm1, "return a.b.c")
    end

    test "set multiple path (check no overwrite)" do
      vm =
        Luex.init()
        |> Luex.set_value(["a", "b", "c"], "test1")
        |> Luex.set_value(["a", "c"], "test2")

      assert %LCall{return: ["test1", "test2"]} = Luex.do_inline(vm, "return a.b.c, a.c")
    end

    test "use a table in a keypath" do
      vm = Luex.init()
      %LCall{return: table, vm: vm} = Luex.Table.new(vm, %{"key" => 1337})
      kp = ["a", table, "c"]
      vm = Luex.set_value(vm, kp, "test2")

      assert %LCall{return: "test2"} = Luex.get_value(vm, kp)
    end
  end

  describe "get_value/2" do
    test "happy path: a.b.c = [[Test]]; return a" do
      %LCall{vm: vm} = Luex.init() |> Luex.do_inline("a = [[Test]]")
      assert %LCall{return: "Test"} = Luex.get_value(vm, ["a"])
    end
  end

  describe "do_inline/2" do

    test "just some math and return" do 
       assert %Luex.Call{return: [5]}  == Luex.init() |> Luex.do_inline("return 3+2")
    end

    test "run some multiline code and return" do
      vm = Luex.init()

      assert %LCall{return: ["hello", 35], vm: vm} =
               Luex.do_inline(vm, """
                 local a = [[hello]]
                 local b = 35
                 return a, b
               """)

      assert Luex.is_vm(vm)
    end
  end

  describe "configure/2 for require" do
    defmodule RequireTest do
      @behaviour Luex.ExtModule

      @impl true
      def target(), do: "test"

      @impl true
      def loader(vm) do
        {hello, vm} = Luex.Functions.new(vm, fn [name], vm1 -> %LCall{return: ["Hello #{name}"], vm: vm1} end)
        Luex.Table.new(vm, %{"hello" => hello})
      end
    end

    test "basic (happy path)" do
      vm = Luex.init() |> Luex.configure(ext_searcher: [RequireTest])

      assert %LCall{return: ["Hello Lua"]} =
               Luex.do_inline(vm, """
               local rt = require("test")
               return rt.hello("Lua")
               """)
    end

    test "basic not found" do
      vm = Luex.init() |> Luex.configure(ext_searcher: [RequireTest])
      # assert {[false, {:no_module, a, b}], _vm}
      assert_raise Luex.LuaError, ~r/Lua Error: module not found not-real*./, fn ->
        Luex.do_inline(vm, """
        return require("not-real")
        """)
      end
    end
  end
end
