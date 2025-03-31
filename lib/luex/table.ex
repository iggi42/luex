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

  @type data() :: %{key() => Luex.lua_value()}

  @doc """
  allocate a new table in the virtual machine
  """
  @spec new(Luex.vm(), %{key() => Luex.lua_value()}) :: Luex.lua_call(t())
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
    builder = fn k, v, acc -> Map.put(acc, k, v) end
    vm |> deref(tref) |> build(%{}, builder)
  end

  @spec get_keys(Luex.vm(), t()) :: [key()]
  def get_keys(vm, tref) do
    builder = fn k, _v, acc -> [k | acc] end
    vm |> deref(tref) |> build([], builder)
  end

  @spec set_key(Luex.vm(), t(), key(), Luex.lua_value()) :: Luex.vm()
  def set_key(vm, tref, key, val)
      when Luex.is_vm(vm) and Luex.is_lua_table(tref) and Luex.is_lua_value(key) and
             Luex.is_lua_value(val) do
    :luerl_emul.set_table_key(tref, key, val, vm)
  end

  @doc """
  get data from a lua table

  # Example
  ```elixir
  iex> {_, vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   numbers = {"eins", "zwei"}
  ...> \"\"\")
  iex> {numbers, vm} = Luex.get_value(vm, ["numbers"])
  iex> vm = Luex.Table.append_to_array(vm, numbers, "drei")
  iex> Luex.Table.get_data(vm, numbers)
  %{1 => "eins", 2 => "zwei", 3 => "drei"}
  ```

  """
  @spec append_to_array(Luex.vm(), t(), Luex.lua_value()) :: Luex.vm()
  def append_to_array(vm, root_tref, val)
      when Luex.is_vm(vm) and Luex.Records.is_tref(root_tref) do
    table = deref(vm, root_tref)

    max = fn
      k, _, i when Luex.is_lua_number(k) and i >= k -> i
      k, _, i when Luex.is_lua_number(k) and i < k -> k
      # TODO do an actuall lua error instead
      _, _, _ -> throw({Luex, :not_an_array})
    end

    index = build(table, 0, max) + 1
    set_key(vm, root_tref, index, val)
  end

  @spec deref(Luex.vm(), Luex.Records.tref()) :: Luex.Records.table()
  defp deref(vm, tref), do: :luerl_heap.get_table(tref, vm)

  @typep builder(acc) :: (key(), Luex.lua_value(), acc -> acc)

  # normalize from the luerl represenation of a table (array, map, orddict, etc)
  @spec build(Luex.Records.table(), acc, builder(acc)) :: acc when acc: any()
  defp build(table, acc, builder) when Luex.Records.is_table(table) and is_function(builder, 3) do
    # heavily inspiried by luerl: src/luerl.erl : 422ff
    arr = Luex.Records.table(table, :a)
    dict = Luex.Records.table(table, :d)
    ts = :ttdict.fold(builder, acc, dict)
    :array.sparse_foldr(builder, ts, arr)
  end
end
