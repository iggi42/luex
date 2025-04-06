defmodule LuexUserdataTest do
  use ExUnit.Case

  require Luex

  test "create and retrieve a simple userdata" do
    vm = Luex.init()

    input_data = {:nice, make_ref(), self()}

    assert {uref, vm} = Luex.Userdata.new(vm, input_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_userdata(uref)

    assert {output_data, vm} = Luex.Userdata.get_data(vm, uref)
    assert Luex.is_vm(vm)
    assert output_data == input_data
  end

  test "create, update and retrieve a simple userdata" do
    input_data = {:nice, make_ref(), self()}

    vm = Luex.init()
    assert {uref, vm} = Luex.Userdata.new(vm, :lol)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_userdata(uref)

    vm = Luex.Userdata.set_data(vm, uref, input_data)
    assert {output_data, vm} = Luex.Userdata.get_data(vm, uref)
    assert Luex.is_vm(vm)
    assert output_data == input_data
  end
end
