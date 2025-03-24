defmodule LuexUserdataTest do
  use ExUnit.Case

  require Luex

  test "create and retrieve a simple userdata" do
    vm0 = Luex.init()

    input_data = {:nice, make_ref(), self()}

    assert {uref, vm1} = Luex.Userdata.new(vm0, input_data)
    assert Luex.is_vm(vm1)
    assert Luex.is_lua_userdata(uref)

    # vm1 = Luex.set_value(vm1, [:c], tref)
    # assert {[5, 10], vm2} = Luex.do_inline(vm1, "return c.a, c.b")

    assert {output_data, vm2} = Luex.Userdata.get_data(vm1, uref)
    assert Luex.is_vm(vm2)
    assert output_data == input_data
  end
end
