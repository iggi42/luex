defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.
  """

  require Record

  Record.defrecordp(:luerl_vm, Record.extract(:luerl, from_lib: "luerl/include/luerl.hrl"))

  #  record(:luerl, [])
  @opaque lua_vm ::
            {:luerl, any(), any(), any(), any(), any(), any(), any(), any(), any(), any(), any(),
             any()}

  @opaque lua_chunk :: any()
  @type lua_value :: any()

  @spec init() :: lua_vm()
  defdelegate init, to: Luerl

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
