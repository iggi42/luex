defmodule Luex.Records do
  @moduledoc """
  This module contains data 
  """

  require __MODULE__.Utils, as: U

  U.load_luerl_struct(:luerl, "luerl vm instance")
  U.load_luerl_struct(:tstruct, "luerl table structure")
  U.load_luerl_struct(:meta, "internal metatable represenation")

  U.load_luerl_struct(:funref, """
  internal reference to a lua function

  follow reference with `luerl_heap:get_funcdef/2`.
  """)

  U.load_luerl_struct(:lua_func, """
  internal represenation of a lua function, defined in lua.
  """)

  U.load_luerl_struct(:erl_func, """
  internal represenation of a lua function, defined in BEAM function (written in Erlang / Elixir / etc)
  """)
end
