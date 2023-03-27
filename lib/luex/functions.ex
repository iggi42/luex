defmodule Luex.Functions do
  require Luex.Records, as: Recs

  @opaque t() :: Recs.erl_func() | Recs.lua_func()
  defguard is_fun(v) when Recs.is_erl_func(v) or Recs.is_lua_func(v)

  # TODO specify tighter
  @type input() :: (any(), any() -> {[Luex.lua_value()], Luex.vm()})

  @spec new(Luex.vm(), input()) :: {t(), Luex.vm()}
  def new(vm, input) do
    throw(:notimplemented)
  end
end
