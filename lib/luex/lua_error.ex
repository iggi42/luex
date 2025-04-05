defmodule Luex.LuaError do
  defexception [:reason, :vm, :og]

  @impl Exception
  def message(%{reason: r, vm: _vm}) do
    # TODO implement a prober error message
    "Lua Error: #{format_error(r)}"
  end

  def format_error({:no_module, m, estr}) do
    "module not found #{to_string(m)}, #{to_string(estr)}"
  end

  def format_error(reason) do
    :luerl_lib.format_error(reason)
  end

  @doc """
    macro pattern match the lua errors luerl throws.
  """
  defmacro luerl_error(reason, vm) do
    quote do
      %ErlangError{original: {:lua_error, unquote(reason), unquote(vm)}}
    end
  end

  @doc """
  catches the lua error implementation of luerl and converts these to `Luex.LuaError` exceptions.
  """
  defmacro wrap(do: block) do
    quote do
      try do
        unquote(block)
      rescue
        err in ErlangError ->
          case err do
            unquote(__MODULE__).luerl_error(reason, vm) ->
              raise Luex.LuaError, reason: reason, vm: vm, og: err

            _ ->
              reraise err, __STACKTRACE__
          end
      end
    end
  end
end
