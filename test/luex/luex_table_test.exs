defmodule LuexTableTest do
  use ExUnit.Case

  require Luex

  test "crud on a simple map" do
    vm = Luex.init()

    input_data = %{
      :a => 5,
      :b50 => 10,
#     "hello" => "world"
    }

    assert {tref, vm} = Luex.Table.new(vm, input_data)
    assert Luex.is_vm(vm)

  end

end
