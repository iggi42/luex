defmodule LuexTableTest do
  use ExUnit.Case

  doctest Luex.Table

  alias Luex.CallResult, as: LCall
  require Luex

  test "create and read a simple map" do
    vm = Luex.init()

    input_data = %{
      "a" => 5,
      "hello" => "world"
    }

    assert %LCall{return: tref, vm: vm} = Luex.Table.new(vm, input_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(tref)

    vm = Luex.set_value(vm, ["c"], tref)
    assert %LCall{return: [5, "world"], vm: vm} = Luex.do_inline(vm, "return c.a, c.hello")

    assert input_data == Luex.Table.get_data(vm, tref)
  end

  test "drop :nil values in tables" do
    vm = Luex.init()

    input_data = %{
      "a" => nil,
      "hello" => "world"
    }

    assert %LCall{return: tref, vm: vm} = Luex.Table.new(vm, input_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(tref)

    assert %{"hello" => "world"} == Luex.Table.get_data(vm, tref)
  end

  test "add table into" do
    vm = Luex.init()

    a_data = %{
      "a" => "world"
    }

    assert %LCall{return: a_tref, vm: vm} = Luex.Table.new(vm, a_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(a_tref)

    b_data = %{"b" => a_tref, "x" => 42}
    assert %LCall{return: b_tref, vm: vm} = Luex.Table.new(vm, b_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_table(b_tref)

    vm = Luex.set_value(vm, ["c"], b_tref)
    assert %LCall{return: [42, "world"]} = Luex.do_inline(vm, "return c.x, c.b.a")
  end

  test "get key" do
    vm = Luex.init()

    assert %LCall{vm: vm} =
             Luex.do_inline(vm, """
             tes = {
               t = 1337;
             };
             """)

    %LCall{return: tes, vm: vm} = Luex.get_value(vm, ["tes"])
    assert %LCall{return: 1337} = Luex.Table.get_key(vm, tes, "t")
  end

  test "update table" do
    %LCall{return: io_tref, vm: vm} = Luex.init() |> Luex.get_value(["io"])
    vm = Luex.Table.set_key(vm, io_tref, "wa", 1337)
    assert %LCall{return: 1337} = Luex.get_value(vm, ["io", "wa"])
  end
end
