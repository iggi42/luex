defmodule LuexUserdataTest do
  use ExUnit.Case

  require Luex

  alias Luex.CallResult, as: LCall

  test "create and retrieve a simple userdata" do
    vm = Luex.init()

    input_data = {:nice, make_ref(), self()}

    assert %LCall{return: uref, vm: vm} = Luex.Userdata.new(vm, input_data)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_userdata(uref)

    assert %LCall{return: output_data, vm: vm} = Luex.Userdata.get_data(vm, uref)
    assert Luex.is_vm(vm)
    assert output_data == input_data
  end

  test "create, update and retrieve a simple userdata" do
    input_data = {:nice, make_ref(), self()}

    vm = Luex.init()
    assert %LCall{return: uref, vm: vm} = Luex.Userdata.new(vm, :lol)
    assert Luex.is_vm(vm)
    assert Luex.is_lua_userdata(uref)

    vm = Luex.Userdata.set_data(vm, uref, input_data)
    assert %LCall{return: output_data, vm: vm} = Luex.Userdata.get_data(vm, uref)
    assert Luex.is_vm(vm)
    assert output_data == input_data
  end

  test "create, update and retrieve a simple userdata via resultcall pipeline" do
    input_data = {:nice_6, make_ref(), self()}

    # pipeline didn't elegantly work here, because we need the uref value extracted "mid" pipeline
    cr = %LCall{return: uref} = Luex.init() |> Luex.Userdata.new(:lol)
 
   assert cr
    |> Luex.Userdata.set_data(input_data)
    |> Luex.Userdata.get_data(uref)
    |> then(&( &1.return ))
    == input_data
  end
end
