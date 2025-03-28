defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.

  A lot of the types are kept as opaque to allow swichting out lua backends in the future.
  If you need to it open up, you need to read the source code anyways.
  """

  require Luex.LuaError
  require Luex.Records

  @type vm() :: Luex.Records.luerl()
  defguard is_vm(val) when Luex.Records.is_luerl(val)

  @typedoc """
  A keypath describes a list of keys, to navigate nested tables.

  For example `package.path`  is a keypath with the elixir representation of `["package", "path"]`.
  """
  @type keypath() :: [String.t()]

  @typedoc """
  This type can representation any lua type.
  """
  @type lua_value() ::
          lua_nil()
          | lua_bool()
          | lua_string()
          | lua_number()
          | lua_table()
          | lua_userdata()
          | lua_fun()

  @typedoc """
  literal type representation of the lua `nil` value via atom `:nil`
  """
  @type lua_nil() :: nil
  defguard is_lua_nil(v) when v == nil

  @typedoc """
  literal type representation of lua boolean values via elixir booleans
  """
  @type lua_bool() :: boolean()
  defguard is_lua_bool(v) when is_boolean(v)

  @typedoc """
  literal type representation of lua string values via elixir strings
  """
  @type lua_string() :: String.t()
  defguard is_lua_string(v) when is_bitstring(v)

  @typedoc """
  literal type representation of number values via elixir floats.
  """
  @type lua_number() :: float()
  defguard is_lua_number(v) when is_number(v)

  @typedoc """
  references a table in a lua virtual machine.
  See `Luex.Table` for more information on how to handle this value.
  """
  @type lua_table() :: Luex.Table.t()
  defguard is_lua_table(v) when Luex.Records.is_tref(v)

  @typedoc """
  references a userdata value in a lua virtual machine.
  See `Luex.Userdata` for more information on how to handle this value.
  """
  @type lua_userdata() :: Luex.Records.usdref()
  defguard is_lua_userdata(v) when Luex.Records.is_usdref(v)

  @typedoc """
  representation of a lua function.
  See `Luex.Functions` for more information on how to handle this value.
  """
  @type lua_fun() :: Luex.Records.erl_mfa() | Luex.Records.erl_func() | Luex.Records.lua_func()
  defguard is_lua_fun(v)
           when Luex.Records.is_erl_mfa(v) or Luex.Records.is_erl_func(v) or
                  Luex.Records.is_lua_func(v)

  @type lua_chunk() :: Luex.Records.erl_func() | Luex.Records.funref()
  defguard is_lua_chunk(v) when Luex.Records.is_erl_func(v) or Luex.Records.is_funref(v)

  @doc """
  `is_lua_value` checks looks like any representation of a value in a lua vm
  """
  defguard is_lua_value(value)
           when is_lua_nil(value) or is_lua_bool(value) or is_lua_fun(value) or
                  is_lua_string(value) or is_lua_number(value) or is_lua_table(value) or
                  is_lua_userdata(value) or is_lua_fun(value) or is_lua_chunk(value)

  @typedoc """
  input type for encode/2
  """
  @type encoding_input() ::
          atom()
          | binary()
          | number()
          | [encoding_input()]
          | [{encoding_input(), encoding_input()}]
          | %{encoding_input() => encoding_input()}
          | {:userdata, any()}

  @doc """
    This is how elixir values are encoded into lua values, by luerl.
    ```mermaid
    graph LR;
      ex_nil(nil):::elixir <---> lua_nil(nil):::lua;
      ex_bool(boolean):::elixir <--> lua_bool(boolean):::lua;
      ex_float(float):::elixir <--> lua_number(number):::lua;
      ex_userdata(userdata tuple):::elixir <--> lua_userdata(raw userdata):::lua;
      ex_fun(fun/2):::elixir <--> lua_fun(function):::lua;

      ex_atom(other atoms):::elixir --> lua_string(string):::lua;
      ex_string(String.t):::elixir --> lua_string;
      ex_binary(binary):::elixir --"no garantee printable"--> lua_string;
      ex_binary <-- lua_string;

      ex_map(map):::elixir ---> lua_table(table):::lua;
      ex_keyword_list(keyword list):::elixir <---> lua_table
      ex_list(other list):::elixir --"index as key"--> lua_table
      lua_table --> ex_keyword_list

    classDef default stroke-width:3px;
    classDef lua stroke:blue;
    classDef elixir stroke:#A020F0;
    ```
    Tuples are only allowed as keyword lists items and to indicate userdata.
  """
  # maybe don't deprecate, but rename with emphasis on recursive loading, and only for _input_ into lua, not output (bc rec tables in lua)
  @deprecated "luex will move away from luerl style encoding of values"
  # TODO move the mermaid diagram to somewhere useful ()
  @spec encode(vm(), encoding_input()) :: {lua_value(), vm()}
  defdelegate encode(vm, encode_me), to: Luerl

  @type input_value() ::
          nil
          | boolean()
          | number()
          | String.t()
          | Luex.Table.input()
          | Luex.Functions.input()
          | {:userdata, any()}

  @doc """
    an attempt at doing Luerl.encode/2 better.

   not sure if having such a function at all is a good idea
  """
  @spec load_value(vm(), input_value()) :: {lua_value(), vm()}
  # literals
  def load_value(vm, nil) when is_vm(vm), do: {nil, vm}
  def load_value(vm, true) when is_vm(vm), do: {true, vm}
  def load_value(vm, false) when is_vm(vm), do: {false, vm}
  def load_value(vm, n) when is_vm(vm) and is_number(n), do: {n, vm}
  def load_value(vm, s) when is_vm(vm) and is_binary(s), do: {s, vm}
  # referenced values
  def load_value(vm, m) when is_vm(vm) and is_map(m), do: Luex.Table.new(vm, m)
  def load_value(vm, {:userdata, payload}) when is_vm(vm), do: Luex.Userdata.new(vm, payload)
  def load_value(vm, f) when is_vm(vm) and is_function(f, 2), do: Luex.Functions.new(vm, f)

  @spec set_value(vm(), keypath(), lua_value()) :: vm()
  def set_value(vm, keypath, value) when is_vm(vm) and is_list(keypath) and is_lua_value(value) do
    Luex.LuaError.wrap do
      set_value1(vm, keypath, value)
    end
  end

  defp set_value1(vm, keypath, value) do
    vm
    |> load_base(keypath)
    |> Luerl.set_table1(keypath, value)
  end

  @spec get_value(vm(), keypath()) :: {lua_value(), vm()}
  def get_value(vm, keypath) when is_vm(vm) and is_list(keypath) do
    Luex.LuaError.wrap do
      get_value1(vm, keypath)
    end
  end

  defp get_value1(vm, keypath), do: Luerl.get_table1(vm, keypath)

  @doc """
  create a new lua virtual machine
  """
  @spec init() :: vm()
  defdelegate init, to: Luerl

  @doc """
  run a string as lua code in the given vm.

  # Example


    ```elixir
    iex> vm0 = Luex.init()
    iex> {[5], _vm1} = Luex.do_inline(vm0, "return 3+2")
    ```

  """
  @spec do_inline(vm(), String.t()) :: {[lua_value()], vm()}
  def do_inline(vm, program) do
    Luex.LuaError.wrap do
      Luerl.do(vm, program)
    end
  end

  @doc """
  run the lua file at `path` in the given vm.

  # Example

    ```elixir
    iex> vm0 = Luex.init()
    iex> {[5], _vm1} = Luex.do_file(vm0, "./test/return_5.lua")
    ```

  """
  @spec do_file(vm(), Path.t()) :: {[lua_value()], vm()}
  def do_file(vm, path) do
    Luex.LuaError.wrap do
      Luerl.dofile(vm, to_charlist(path))
    end
  end

  # TODO write docs
  @spec do_chunk(vm(), lua_chunk(), [lua_value()]) :: {[lua_value()], vm()}
  def do_chunk(vm, chunk, args \\ []) do
    Luex.LuaError.wrap do
      Luerl.call(vm, chunk, args)
    end
  end

  # TODO write docs
  @spec install(vm(), module()) :: vm()
  def install(vm, module, args \\ []) do
    {vm, table} = module.table(vm)
    target = args[:target] || module.target()

    # direct setting on root of _G is subject to change.
    # registering it for require is the idea for the future
    Luex.set_value(vm, [ "luex" | target ], table)
  end

  # copy from ava
  # ensures tables are loaded with atleast an empty table
  @spec load_base(Luex.vm(), Luex.keypath()) :: Luex.vm()
  defp load_base(vm, keypath) when is_vm(vm) and is_list(keypath) do
    load_base(vm, keypath, [])
  end

  defp load_base(vm, [_head], _ensured), do: vm

  defp load_base(vm, [head | rest_target], ensured) do
    target = ensured ++ [head]

    {t, vm} = Luerl.get_table1(vm, target)

    vm =
      case t do
        nil -> Luerl.set_table(vm, target, %{})
        t when is_lua_table(t) -> vm
        _other -> throw("[Luex] base type mismatch")
      end

    load_base(vm, rest_target, target)
  end
end
