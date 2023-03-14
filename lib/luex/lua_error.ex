defmodule Luex.LuaError do
  defexception [:reason, :vm]

  require Luex.Types, as: LTypes

  @impl Exception
  def message(%{reason: r, vm: vm}) when LTypes.is_vm(vm) do
    # TODO implement a prober
    "TODO: " <> inspect(__MODULE__) <> ".message/1 " <> inspect(r)
  end

  @doc """
    macro to create the pattern of the expection luerl throws.
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
              raise Luex.LuaError, reason: reason, vm: vm

            e ->
              reraise e, __STACKTRACE__
          end
      end
    end
  end
end
