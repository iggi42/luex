defmodule Luex.Table do
  # TODO implement the Enumerable protocol against lua tables.

  require Luex
  require Luex.Records

  alias Luex.CallResult, as: Call

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

  @type data() :: %{key() => Luex.lua_value()}

  @type folder(acc) :: (key(), Luex.lua_value(), acc -> acc)

  @doc """
  fold over each key value pair of a referenced table
  """
  # normalize from the luerl represenation of a table (array, map, orddict, etc)
  @spec fold(Luex.vm(), Luex.lua_table(), acc, folder(acc)) :: acc when acc: any()
  def fold(vm, tref, acc, folder)
      when Luex.is_vm(vm) and Luex.is_lua_table(tref) and is_function(folder, 3) do
    table = :luerl_heap.get_table(tref, vm)
    # heavily inspiried by luerl: src/luerl.erl : 422ff
    arr = Luex.Records.table(table, :a)
    dict = Luex.Records.table(table, :d)
    ts = :ttdict.fold(folder, acc, dict)
    :array.sparse_foldr(folder, ts, arr)
  end

  @doc """
  allocate a new table in the virtual machine
  """
  @spec new(Luex.vm(), %{key() => Luex.lua_value()}) :: Luex.lua_call(Luex.lua_table())
  def new(vm, input) when Luex.is_vm(vm) and is_map(input) do
    :luerl_heap.alloc_table(input, vm) |> Call.from_luerl()
  end


  @doc """
  turn a call result into an elixir map. not recrusive!

  # Example
  ```elixir
  iex>  Luex.init()
  ...>  |> Luex.do_inline(\"\"\"
  ...>     a = {}
  ...>     a.x = 42
  ...>     a.hello = "world"
  ...>   \"\"\")
  ...>  |> Luex.get_value(["a"])
  ...>  |> Luex.Table.get_data()
  %{"x" => 42, "hello" => "world"}
  ```
  """
  @spec get_data(Luex.lua_call(Luex.lua_table())) :: %{key() => Luex.lua_value()}
  def get_data(%Luex.CallResult{ vm: vm, return: table }), do: get_data(vm, table)

  @doc """
  get data from a lua table, not recursive

  # Example
  ```elixir
  iex> %Luex.CallResult{vm: vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   a = {}
  ...>   a.x = 42
  ...>   a.hello = "world"
  ...> \"\"\")
  iex> %Luex.CallResult{return: a_tref, vm: vm} = Luex.get_value(vm, ["a"])
  iex> Luex.Table.get_data(vm, a_tref)
  %{"x" => 42, "hello" => "world"}
  ```
  """
  @spec get_data(Luex.vm(), Luex.lua_table()) :: %{key() => Luex.lua_value()}
  def get_data(vm, tref) do
    fold(vm, tref, %{}, fn
      k, v, acc -> Map.put(acc, k, v)
    end)
  end

  @spec get_keys(Luex.vm(), Luex.lua_table()) :: [key()]
  def get_keys(vm, tref) do
    fold(vm, tref, [], fn
      k, _v, acc -> [k | acc]
    end)
  end

  @spec get_key(Luex.vm(), Luex.lua_table(), key()) :: Luex.lua_call(Luex.lua_value())
  def get_key(vm, tref, key) do
    :luerl_emul.get_table_key(tref, key, vm) |> Call.from_luerl()
  end

  @spec set_key(Luex.vm(), Luex.lua_table(), key(), Luex.lua_value()) :: Luex.vm()
  def set_key(vm, tref, key, val)
      when Luex.is_vm(vm) and Luex.is_lua_table(tref) and Luex.is_lua_value(key) and
             Luex.is_lua_value(val) do
    :luerl_emul.set_table_key(tref, key, val, vm)
  end
end
