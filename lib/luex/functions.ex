defmodule Luex.Functions do
  require Luex.Records
  require Luex

  @opaque t() :: Luex.lua_fun()

  @typedoc """
  You can import beam functions with this signature
  """
  @type input() :: ([Luex.lua_value()], Luex.vm() -> Luex.lua_call([Luex.lua_value()]))

  @doc """
  Import an elixir / erlang function into the lua vm to be called by lua code.

  # Example 
  ```elixir
  iex> fun = fn([a], fun_vm) ->
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
  @spec new(Luex.vm(), input()) :: Luex.lua_call(t())
  def new(vm, input) when Luex.is_vm(vm) and is_function(input, 2) do
    {Luex.Records.erl_func(code: input), vm}
  end

  @spec call(Luex.vm(), t(), [Luex.lua_value()]) :: Luex.lua_call([Luex.lua_value()])
  def call(vm, lfun, largs) when Luex.is_vm(vm) do
    :luerl_emul.functioncall(lfun, largs, vm)
  end
end
