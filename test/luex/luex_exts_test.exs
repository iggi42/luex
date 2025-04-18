defmodule Luex.LuexExtsTest do
require Luex

  use ExUnit.Case

  describe "use Luex.ExtModule" do
    defmodule Happy do
      use Luex.ExtModule

      lua_ext "test" do
         a when Luex.is_lua_string(a) -> :ok
      end

    end

    test "setup happy" do
      vm = Luex.init() |> Luex.configure(ext_searcher: [ Happy ])
      assert Luex.is_vm(vm)
    end
    
    test "call happy" do
      
    end
      
  end
  
end
