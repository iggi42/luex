defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.
  """

  require Record
  require Luex.Records, as: R

  @opaque lua_vm :: R.luerl_vm()
  defguard is_lua_vm(v) when R.is_luerl_luerl(v)

  @opaque lua_chunk :: any()
  @type lua_value :: any()

  @typedoc """
  This is only meant representing uncaught errors, that happened within lua.
  """
  @type lua_error :: any()

  @spec init() :: lua_vm()
  defdelegate init, to: Luerl

  @spec do_lua(lua_vm(), String.t(), [lua_value()]) :: {:ok, [lua_value()], lua_vm()}  | {:error, lua_error(), lua_vm()}
  def do_lua(vm, program, args \\ []) do
    Luerl.call(vm, program, args)
  rescue
    e ->
      case e do
        %ErlangError{original: {:lua_error, reason, vm}} ->
        {:error, reason, vm}

        exc ->
          reraise exc, __STACKTRACE__
      end
  end

  @doc ~S'''
  Executes a precompiled chunk.
  '''
  @spec do_chunk(lua_vm(), lua_chunk(), [lua_value()]) :: {:ok, {lua_value(), lua_vm()}}
  def do_chunk(s0, chunk, args \\ []) do
    {:ok, Luerl.call(s0, chunk, args)}
  rescue
    e ->
      case e do
        %ErlangError{original: {:lua_error, _reason, _vm} = lua_error} ->
          {:run_error, lua_error}

        exc ->
          reraise exc, __STACKTRACE__
      end
  end
end
