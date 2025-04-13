defmodule Luex.Table.Array do
  @moduledoc """
  access Lua arrays

  Lua arrays are tables with their keys being the integer index of a stored value
  """
  alias Luex.Table
  require Luex

  @doc """
  check if a table is a well formed lua array.

  # Example
  ```elixir
  iex> {[array], vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   return {"a", "b", "c"};
  ...> \"\"\")
  iex> Luex.Table.Array.lua_array?(vm, array)
  true
  iex> {[no_array], vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   return { a = 123; b = 567; };
  ...> \"\"\")
  iex> Luex.Table.Array.lua_array?(vm, no_array)
  false
  ```

  """
  @spec lua_array?(Luex.vm(), Luex.lua_table()) :: boolean()
  def lua_array?(vm, ref) do
    # TODO is_array implmentation
    vm |> Luex.Table.get_keys(ref) |> Enum.all?(&Luex.is_lua_number/1)
  end

  @doc """
  build a elixir list from a lua array

  # Example
  ```elixir
  iex> {[array], vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   return {"a", "b", "c"};
  ...> \"\"\")
  iex> Luex.Table.Array.to_list(vm, array)
  ["a", "b", "c"]
  ```

  """
  @spec to_list(Luex.vm(), Luex.lua_table()) :: [Luex.lua_value()]
  def to_list(vm, ref) do
    fold(vm, ref, [], fn _i, val, acc -> [val | acc] end) |> Enum.reverse()
  end

  @doc "build a lua array from elixir list"
  @spec new(Luex.vm(), [Luex.lua_value()]) :: {Luex.lua_table(), Luex.vm()}
  def new(vm, input) when is_list(input) do
    acc = {1, %{}}

    folder = fn el, {i, acc} ->
      {i + 1, Map.put(acc, i, el)}
    end

    {_max, data} = List.foldl(input, acc, folder)
    Luex.Table.new(vm, data)
  end

  @doc """
  append lua value to a lua array

  # Example
  ```elixir
  iex> {_, vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   numbers = {"eins", "zwei"}
  ...> \"\"\")
  iex> {numbers, vm} = Luex.get_value(vm, ["numbers"])
  iex> vm = Luex.Table.Array.append(vm, numbers, "drei")
  iex> Luex.Table.get_data(vm, numbers)
  %{1 => "eins", 2 => "zwei", 3 => "drei"}
  ```

  """
  @spec append(Luex.vm(), Luex.lua_table(), Luex.lua_value()) :: Luex.vm()
  def append(vm, root_tref, val)
      when Luex.is_vm(vm) and Luex.is_lua_table(root_tref) do
    # get the highest root
    max =
      Luex.Table.fold(vm, root_tref, 0, fn
        k, _, i when Luex.is_lua_number(k) and i >= k ->
          i

        k, _, i when Luex.is_lua_number(k) and i < k ->
          k

        # TODO do an actuall lua error instead
        k, _, _ ->
          raise Luex.Table.NotAnArrayException,
            wrong_key: k,
            table: root_tref
      end)

    Luex.Table.set_key(vm, root_tref, max + 1, val)
  end

  @type folder(acc) :: (index :: Luex.lua_number(), element :: Luex.lua_value(), acc -> acc)

  # TODO analyze performance on this
  @doc """
  folds the array from the lowest to the hightest index

  # Example
  ```elixir
  iex> {[numbers], vm} = Luex.init() |> Luex.do_inline(\"\"\"
  ...>   numbers = {"eins", "zwei", "drei"}
  ...>   return numbers
  ...> \"\"\")
  iex> Luex.Table.Array.fold(vm, numbers, "null", fn _index, value, acc -> "\#{acc}, \#{value}" end)
  "null, eins, zwei, drei"
  ```
  """
  @spec fold(Luex.vm(), Luex.lua_table(), acc, folder(acc)) :: acc when acc: any()
  def fold(vm, ref, acc, folder) when Luex.is_vm(vm), do: fold1(vm, ref, acc, 1, folder)

  defp fold1(vm, ref, acc, i, folder) do
    # i is our key here
    # TODO test if metamethods work here
    # potential endless loop
    case Table.get_key(vm, ref, i) do
      {nil, _vm} ->
        acc

      {val, vm} ->
        acc = folder.(i, val, acc)
        fold1(vm, ref, acc, i + 1, folder)
    end
  end
end
