defmodule LuexTableTest do
  use ExUnit.Case

  doctest Luex.Table

  require Luex

  test "create and read a simple map" do
    vm0 = Luex.init()

    input_data = %{
      "a" => 5,
      "hello" => "world"
    }

    assert {tref, vm1} = Luex.Table.new(vm0, input_data)
    assert Luex.is_vm(vm1)
    assert Luex.is_lua_table(tref)

    vm1 = Luex.set_value(vm1, ["c"], tref)
    assert {[5, "world"], vm2} = Luex.do_inline(vm1, "return c.a, c.hello")

    assert input_data == Luex.Table.get_data(vm2, tref)
  end

  test "drop :nil values in tables" do
    vm0 = Luex.init()

    input_data = %{
      "a" => nil,
      "hello" => "world"
    }

    assert {tref, vm1} = Luex.Table.new(vm0, input_data)
    assert Luex.is_vm(vm1)
    assert Luex.is_lua_table(tref)

    assert %{"hello" => "world"} == Luex.Table.get_data(vm1, tref)
  end

  test "add table into" do
    vm = Luex.init()

    a_data = %{
      "a" => "world"
    }

    assert {a_tref, vm} = Luex.Table.new(vm, a_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(a_tref)

    b_data = %{"b" => a_tref, "x" => 42}
    assert {b_tref, vm} = Luex.Table.new(vm, b_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(b_tref)

    vm = Luex.set_value(vm, ["c"], b_tref)
    assert {[42, "world"], _vm} = Luex.do_inline(vm, "return c.x, c.b.a")
  end

  test "get key" do
    vm = Luex.init()

    assert {_, vm} =
             Luex.do_inline(vm, """
             tes = {
               t = 1337;
             };
             """)

    {tes, vm} = Luex.get_value(vm, ["tes"])
    assert {1337, _vm} = Luex.Table.get_key(vm, tes, "t")
  end

  test "update table" do
    {io_tref, vm} = Luex.init() |> Luex.get_value(["io"])
    vm = Luex.Table.set_key(vm, io_tref, "wa", 1337)
    assert {1337, _vm} = Luex.get_value(vm, ["io", "wa"])
  end
end
