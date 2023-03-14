defmodule Luex.ExtModule do
  @callback install(Luex.lua_vm()) :: {Luex.Records.tref(), Luex.lua_vm()}

  # based on ExUnit.Case, especially register_test & test
  defmacro __using__() do
    %{module: mod} = __CALLER__
    Module.register_attribute(mod, :luex_exts, accumulate: true)

    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  # maybe allow for number keys too in the future? 
  @spec register_extension(module(), String.t()) :: atom()
  def register_extension(mod, key) do
    id = String.to_atom("luex_ext_" <> key)
    Module.put_attribute(mod, :luex_exts, {id, key})
    id
  end

  defmacro lua_ext(key, do: exec) do
    %{module: mod} = __CALLER__
    local = register_extension(mod, key)

    quote do
      def unquote(local)(args) do
        unquote(exec)
      end
    end
  end
end
