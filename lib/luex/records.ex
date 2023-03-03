defmodule Luex.Records do
  @moduledoc """
  This module contains data 
  """

  require __MODULE__.Utils, as: U

  U.load_luerl_struct(:luerl, "luerl vm instance")
  U.load_luerl_struct(:tstruct, "luerl table structure")
  U.load_luerl_struct(:meta, "internal metatable represenation")
end
