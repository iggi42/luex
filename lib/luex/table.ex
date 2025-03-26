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

  @doc """
  get data from a lua table

  # Example
  ```elixir
  iex> {_, vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   a = {}
  ...>   a.x = 42
  ...>   a.hello = "world"
  ...> \"\"\")
  iex> {a_tref, vm} = Luex.get_value(vm, ["a"])
  iex> Luex.Table.get_data(vm, a_tref)
  %{"x" => 42, "hello" => "world"}
  ```
  """
  @spec get_data(Luex.vm(), t()) :: %{key() => Luex.lua_value()}
  def get_data(vm, tref) do
    :luerl_heap.get_table(tref, vm) |> normalize()
  end

  # normalize from the luerl represenation of a table (array, map, orddict, etc)
  @spec normalize(Luex.Records.table()) :: %{key() => Luex.lua_value()}
  defp normalize(table) when Luex.Records.is_table(table) do
    # heavily inspiried by luerl: src/luerl.erl : 422ff
    arr = Luex.Records.table(table, :a)
    dict = Luex.Records.table(table, :d)
    fun = fn k, v, acc -> [{k, v} | acc] end
    ts = :ttdict.fold(fun, [], dict)
    :array.sparse_foldr(fun, ts, arr) |> Map.new()
  end
end
