defmodule Luex.Table do
  # TODO implement the Enumerable protocol against lua tables.

  require Luex
  require Luex.Records

  @type t() :: Luex.Records.tref()

  @typedoc """
  Every lua type, execpt for `nil` can be used as key in a table.
  """
  @type key() ::
          Luex.lua_bool()
          | Luex.lua_string()
          | Luex.lua_number()
          | Luex.lua_table()
          | Luex.lua_userdata()
          | Luex.lua_fun()

  @type input() :: %{key() => Luex.lua_value()}

  @spec new(Luex.vm(), map()) :: {t(), Luex.vm()}
  def new(vm, input) when Luex.is_vm(vm) and is_map(input) do
    input |> Map.to_list() |> :luerl_heap.alloc_table(vm)
  end

  @doc """
  crashes with an erlang error from https://www.erlang.org/doc/man/maps.html#update_with-3 if the key isn't there.
  uncool.
  """
  @spec update(Luex.vm(), t(), Luex.lua_value()) :: Luex.vm()
  def update(vm, tref, _val) when Luex.is_vm(vm) and Luex.is_lua_table(tref) do
    #   :luerl_heap.upd_table(tref, key,  vm)
    vm
  end

  @spec get_data(Luex.vm(), t()) :: %{key() => Luex.lua_value()}
  def get_data(vm, tref) do
    vm
    |> get_tstruct(tref)
    |> Luex.Records.tstruct(:data)
  end

  @spec get_tstruct(Luex.vm(), t()) :: Luex.Records.tstruct()
  defp get_tstruct(vm, ref), do: :luerl_heap.get_table(ref, vm)
end
