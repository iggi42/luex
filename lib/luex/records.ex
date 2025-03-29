defmodule Luex.Records do
  @moduledoc """
  This module contains extracted luerl records.
  """

  require Luex.Utils, as: U

  U.load_luerl_struct(:luerl, "luerl vm instance")

  U.load_luerl_struct(:table, "interal luerl table type")

  U.load_luerl_struct(:tstruct, "interal table structure",
    data: map() | :orddict.orddict() | :array.array()
  )

  U.load_luerl_struct(:meta, "internal metatable represenation")

  U.load_luerl_struct(:tref, "internal table reference via index")

  U.load_luerl_struct(:funref, """
  internal reference to a lua function

  follow reference with `luerl_heap:get_funcdef/2`.
  """)

  U.load_luerl_struct(:usdref, """
  internal reference to userdata in a virtual machine
  """)

  U.load_luerl_struct(:userdata, "internal structure represenating userdata")

  U.load_luerl_struct(:lua_func, """
  internal represenation of a lua function, defined in lua.
  """)

  U.load_luerl_struct(
    :erl_mfa,
    """
    internal represenation of a lua function, defined in BEAM function via module and function name
    """,
    m: module(),
    f: atom()
  )

  U.load_luerl_struct(
    :erl_func,
    """
    internal represenation of a lua function, defined in BEAM function (written in Erlang / Elixir / etc)
    """,
    code: ([Luex.lua_value()], Luex.vm() -> {[Luex.lua_value()], Luex.vm()})
  )
end
