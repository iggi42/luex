defmodule Luex.Types do
  @moduledoc """
  This modules handles the type conversion.

  A lot of the types are kept as opaque to allow swichting out lua backends in the future.
  If you need to it open up, you need to read the source code anyways.
  """

  require Luex.Records, as: Recs

  @opaque vm :: Recs.luerl()
  defguard is_vm(val) when Recs.is_luerl(val)

  @typedoc """
  A keypath describes a list of keys, to navigate nested tables.

  For example ´package.path´  is a keypath with the elixir representation of `[:package, :path]`
  """
  @type keypath :: [atom()]

  @opaque chunk :: R.erl_func() | R.funref()

  @typedoc """
  This type can representation any lua type.
  """
  @type value :: any()

  alias Luex.Records

  @type lua_nil :: nil
  @type lua_bool :: boolean()
  @type lua_string :: String.t()
  @type lua_number :: float()
  @type lua_table :: Records.table()
  @type lua_fun :: Records.erl_func() | Records.lua_func()
end
