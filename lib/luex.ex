defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.
  """

  require Luex.Types, as: LuaType
  require Luex.LuaError, as: LuaError

  @spec init() :: LuaType.lua_vm()
  defdelegate init, to: Luerl

  @spec do_inline(LuaType.lua_vm(), String.t()) :: {[LuaType.lua_value()], LuaType.lua_vm()}
  def do_inline(vm, program) do
    LuaError.wrap do
      Luerl.do(vm, program)
    end
  end

  @spec do_chunk(LuaType.lua_vm(), LuaType.lua_chunk(), [LuaType.lua_value()])
    :: {[LuaType.lua_value()], LuaType.lua_vm()}
  def do_chunk(vm, chunk, args \\ []) do
    LuaError.wrap do
      Luerl.call(vm, chunk, args)
    end
  end
end
