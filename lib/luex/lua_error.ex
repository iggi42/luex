defmodule Luex.LuaError do
  defexception [:reason, :vm]

  @impl Exception
  def message(t) do
    "TODO message/1 " <> inspect(t)
  end

  defmacro lua_error(reason, vm) do
    quote do
      %ErlangError{original: {:lua_error, unquote(reason), unquote(vm)}}
    end
  end

  defmacro wrap(do: block) do
    quote do
      try do
        unquote(block)
      rescue
        err in ErlangError ->
          case err do
            unquote(__MODULE__).lua_error(reason, vm) -> {:error, reason, vm}
            e -> reraise e, __STACKTRACE__
          end
      end
    end
  end
end
