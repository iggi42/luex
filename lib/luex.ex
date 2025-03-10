defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.

  A lot of the types are kept as opaque to allow swichting out lua backends in the future.
  If you need to it open up, you need to read the source code anyways.
  """

  require Luex.LuaError
  require Luex.Records
  require Luex.Functions

  @type vm() :: Luex.Records.luerl()
  defguard is_vm(val) when Luex.Records.is_luerl(val)

  @typedoc """
  A keypath describes a list of keys, to navigate nested tables.

  For example `package.path`  is a keypath with the elixir representation of `[:package, :path]`.
  """
  @type keypath() :: [atom()]

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
  """
  @type lua_table() :: Luex.Table.t()
  defguard is_lua_table(v) when Luex.Records.is_tref(v)

  @typedoc """
  references a userdata value in a lua virtual machine.
  """
  @type lua_userdata() :: Luex.Records.usdref()
  defguard is_lua_userdata(v) when Luex.Records.is_usdref(v)

  @type lua_fun() :: Luex.Functions.t()
  defguard is_lua_fun(v) when Luex.Functions.is_fun(v)

  @type lua_chunk() :: Luex.Records.erl_func() | Luex.Records.funref()

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
    This is how elixir values are encoded into lua values.
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
    my attempt at doing Luerl.encode/2 better.
  """
  @spec load_value(vm(), input_value()) :: {lua_value(), vm()}
  # literals
  def load_value(vm, nil), do: {nil, vm}
  def load_value(vm, true), do: {true, vm}
  def load_value(vm, false), do: {false, vm}
  def load_value(vm, n) when is_number(n), do: {n, vm}
  def load_value(vm, s) when is_binary(s), do: {s, vm}
  # referenced values
  def load_value(vm, m) when is_map(m), do: Luex.Table.new(vm, m)
  def load_value(vm, {:userdata, payload}), do: :luerl_heap.alloc_userdata(payload, vm)
  def load_value(vm, f) when is_function(f, 2), do: Luex.Functions.new(vm, f)

  @spec init() :: vm()
  defdelegate init, to: Luerl

  @doc """
  JUST AN IDEA. NOT IMPLEMENTED.
  See `luerl/src/luerl_sandbox.erl` for ideas / backend.
  """
  @spec init_sandbox() :: vm()
  def init_sandbox, do: throw(:not_implemented)

  @spec do_inline(vm(), String.t()) :: {[lua_value()], vm()}
  def do_inline(vm, program) do
    Luex.LuaError.wrap do
      Luerl.do(vm, program)
    end
  end

  @spec eval_file(vm(), Path.t()) :: {[lua_value()], vm()}
  def eval_file(vm, path) do
    Luex.LuaError.wrap do
      Luerl.dofile(vm, to_charlist(path))
    end
  end

  @spec do_chunk(vm(), lua_chunk(), [lua_value()]) :: {[lua_value()], vm()}
  def do_chunk(vm, chunk, args \\ []) do
    Luex.LuaError.wrap do
      Luerl.call(vm, chunk, args)
    end
  end
end
