defmodule Luex.Functions do
  require Luex.Records
  require Luex

  @opaque t() :: Luex.lua_fun()

  # TODO specify tighter
  @type input() :: (Luex.vm(), [Luex.lua_value()] -> {[Luex.lua_value()], Luex.vm()})

  @doc """
  Import an elixir / erlang function into the lua vm to be called by lua code.

  # Example 
  ```elixir
  iex> require Luex
  iex> fun = fn([a], fun_vm) when Luex.is_lua_string(a) ->
  ...>    {["hello " <> a], fun_vm}
  ...> end
  iex> {luerl_fun, vm} = Luex.init() |> Luex.Functions.new(fun)
  iex> vm = Luex.set_value(vm, ["a", "b"], luerl_fun)
  iex> {result, _vm} = Luex.do_inline(vm, \"\"\"
  ...>   return a.b("Demo")
  ...> \"\"\")
  iex> result
  ["hello Demo"]
  ```

  """
  @spec new(Luex.vm(), input()) :: {t(), Luex.vm()}
  def new(vm, input) when Luex.is_vm(vm) and is_function(input, 2) do
    {Luex.Records.erl_func(code: input), vm}
  end

  @spec call(Luex.vm(), t(), [Luex.lua_value()]) :: {[Luex.lua_value()], Luex.vm()}
  def call(vm, lfun, largs) when Luex.is_vm(vm) do
    :luerl_emul.functioncall(lfun, largs, vm)
  end
end
