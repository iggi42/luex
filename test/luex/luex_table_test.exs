defmodule LuexTableTest do
  use ExUnit.Case

  require Luex

  test "create a simple map" do
    vm0 = Luex.init()

    input_data = %{
      "a" => 5,
      "hello" => 10
      #     "hello" => "world"
    }

    assert {tref, vm1} = Luex.Table.new(vm0, input_data)
    assert Luex.is_vm(vm1)
    assert Luex.is_lua_table(tref)

    vm1 = Luex.set_value(vm1, ["c"], tref)
    assert {[5, 10], vm2} = Luex.do_inline(vm1, "return c.a, c.hello")

    assert input_data == Luex.Table.get_data(vm2, tref)
  end
end
