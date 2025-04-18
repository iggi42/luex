defmodule Luex.ExtModule do
  # not ready to be used (yet)
  # this is module is more an experiment than anything else
  @moduledoc false
  @callback loader(lua_args :: [Luex.lua_value()], Luex.vm()) :: Luex.lua_call([Luex.lua_table()])
  @callback target() :: Luex.lua_string()

  @spec build_loader([module()]) :: Luex.Functions.input()
  def build_loader(ext_module) do
    fn args, vm ->
      {table, vm} = apply(ext_module, :loader, [vm, args])
      {[table], vm}
    end
  end

  # {vm, table} = module.table(vm)
  # target = args[:target] || module.target()

  # based on ExUnit.Case, especially register_test & test
  defmacro __using__() do
    Module.register_attribute(__CALLER__.module, :luex_ext, accumulate: true)

    quote do
      @behaviour unquote(__MODULE__)
      # TODO in late hook build generate loader/1 with data from :luex_ext attribute
    end
  end

  # maybe allow for number keys too in the future? 
  @spec register_extension(module(), String.t()) :: atom()
  defp register_extension(mod, key) do
    # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
    id = String.to_atom("luex_ext_" <> key)
    Module.put_attribute(mod, :luex_ext, {id, key})
    id
  end

  @doc """
  registers an extension.
  """
  defmacro lua_ext(key, vm_name, do: exec) do
    local = register_extension(__CALLER__.module, key)
    user_clauses = Enum.map(exec, fn {:'->', } -> :ok end)

    # TODO compelete this 
    quote do
      @spec unquote(local)
      @luext_ext
      unquote(user_clauses)
      def unquote(local)(args, unquote(vm_name)) do
        fuck
      end
    end
  end

end
