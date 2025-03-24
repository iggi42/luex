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

  @doc """
  allocate a new table in the virtual machine
  """
  @spec new(Luex.vm(), %{key() => Luex.lua_value()}) :: {t(), Luex.vm()}
  def new(vm, input) when Luex.is_vm(vm) and is_map(input) do
    :luerl_heap.alloc_table(input, vm)
  end

  @spec get_data(Luex.vm(), t()) :: %{key() => Luex.lua_value()}
  def get_data(vm, tref) do
    vm |> get_tstruct(tref) |> normalize()
  end

  # normalize from the luerl represenation of a table (array, map, orddict, etc)
  @spec normalize(Luex.Records.tstruct() | Luex.Records.table()) :: %{key() => Luex.lua_value()}
  defp normalize(table) when Luex.Records.is_table(table) do
    # heavily inspiried by luerl: src/luerl.erl : 422ff
    arr = Luex.Records.table(table, :a)
    dict = Luex.Records.table(table, :d)
    fun = fn k, v, acc -> [{k, v} | acc] end
    ts = :ttdict.fold(fun, [], dict)
    :array.sparse_foldr(fun, ts, arr) |> Map.new()
  end

  defp normalize(tstruct) when Luex.Records.is_tstruct(tstruct) do
    throw("normalizing a tstruct!")
    raw_data = tstruct |> Luex.Records.tstruct(:data) |> dbg()

    cond do
      :array.is_array(raw_data) -> raw_data |> :array.to_list() |> Map.new()
      is_list(raw_data) -> Map.new(raw_data)
      is_map(raw_data) -> raw_data
    end
  end

  # @spec decode_tstruct(Luex.vm(), Luex.Records.tstruct()) :: 
  # def decode_tstruct(vm, tref) do
  #   
  # end

  @spec get_tstruct(Luex.vm(), t()) :: Luex.Records.tstruct()
  defp get_tstruct(vm, ref), do: :luerl_heap.get_table(ref, vm)
end
