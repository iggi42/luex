defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.
  """

  # require Record
  require Luex.Records, as: R
  require Luex.LuaError, as: LuaError

  @typedoc """
  A keypath describes a list of keys, to navigate nested tables.

  For example ´package.path´  is a keypath with the elixir representation of `[:package, :path]`
  """
  @type keypath :: [atom()]

  @opaque lua_vm :: R.luerl_vm()
  defguard is_lua_vm(v) when R.is_luerl(v)

  @opaque lua_chunk :: R.erl_func() | R.funref()
  @type lua_value :: any()

  @spec init() :: lua_vm()
  defdelegate init, to: Luerl

  @spec do_inline(lua_vm(), String.t()) :: {[lua_value()], lua_vm()}
  def do_inline(vm, program) do
    LuaError.wrap do
      Luerl.do(vm, program)
    end
  end

  @spec do_chunk(lua_vm(), lua_chunk(), [lua_value()]) :: {[lua_value()], lua_vm()}
  def do_chunk(vm, chunk, args \\ []) do
    LuaError.wrap do
      Luerl.call(vm, chunk, args)
    end
  end
end
