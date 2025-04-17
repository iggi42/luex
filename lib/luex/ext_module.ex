defmodule Luex.ExtModule do
  # not ready to be used (yet)
  # this is module is more an experiment than anything else
  @moduledoc false
  @callback table(Luex.vm()) :: {Luex.lua_table(), Luex.vm()}
  @callback target() :: binary()

  def build_loader(ext_module) do
    fn _args, vm ->
      {table, vm} = apply(ext_module, :table, [vm])
      {[table], vm}
    end
  end

  # {vm, table} = module.table(vm)
  # target = args[:target] || module.target()

  # based on ExUnit.Case, especially register_test & test
  defmacro __using__() do
    Module.register_attribute(__CALLER__.module, :luex_exts, accumulate: true)

    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  # maybe allow for number keys too in the future? 
  @spec register_extension(module(), String.t()) :: atom()
  def register_extension(mod, key) do
    # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
    id = String.to_atom("luex_ext_" <> key)
    Module.put_attribute(mod, :luex_exts, {id, key})
    id
  end

  defmacro lua_ext(key, do: exec) do
    local = register_extension(__CALLER__.module, key)

    # TODO rethink this
    quote do
      def unquote(local)(args) do
        unquote(exec)
      end
    end
  end

end
