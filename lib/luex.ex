defmodule Luex do
  @moduledoc """
  Documentation for `Luex`.

  A lot of the types are kept as opaque to allow swichting out lua backends in the future.
  If you need to it open up, you need to read the source code anyways.
  """

  require Luex.LuaError
  require Luex.Records

  alias Luex.CallResult

  @typedoc """
  represents a lua call, that returned a value and potentially changed the vm state
  """
  @type lua_call(result_type) :: %Luex.CallResult{vm: Luex.vm(), return: result_type} #  {result_type, vm()}

  @type vm() :: Luex.Records.luerl()
  defguard is_vm(val) when Luex.Records.is_luerl(val)

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
  @type lua_table() :: Luex.Records.tref()
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

  # TODO write docs
  @type lua_chunk() :: Luex.Records.erl_func() | Luex.Records.funref()
  defguard is_lua_chunk(v) when Luex.Records.is_erl_func(v) or Luex.Records.is_funref(v)

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

  @doc """
  `is_lua_value` checks looks like any representation of a value in a lua vm
  """
  defguard is_lua_value(value)
           when is_lua_nil(value) or is_lua_bool(value) or is_lua_fun(value) or
                  is_lua_string(value) or is_lua_number(value) or is_lua_table(value) or
                  is_lua_userdata(value) or is_lua_fun(value) or is_lua_chunk(value)

  @typedoc """
  A keypath describes a list of keys, to navigate nested tables.

  For example `package.path`  is a keypath with the elixir representation of `["package", "path"]`.
  """
  @type keypath() :: [lua_value()]

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
  Import an elixir value into a luerl vm.
  This is function recursively loads lists, keyword lists and maps.

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
  # @deprecated "luex will move away from luerl style encoding of values"
  # TODO move the mermaid diagram to somewhere useful ()
  @spec encode(vm(), encoding_input()) :: lua_call(lua_value())
  def encode(vm, encoding_input) do
    vm
    |> Luerl.encode(encoding_input)
    |> CallResult.from_luerl()
  end

  @type input_value() ::
          nil
          | boolean()
          | number()
          | String.t()
          | Luex.Table.data()
          | Luex.Functions.input()
          | {:userdata, any()}

  @doc """
    an attempt at doing Luerl.encode/2 better.

  """
  @spec load_value(vm(), input_value()) :: lua_call(lua_value())
  # literals
  def load_value(vm, nil) when is_vm(vm), do: %CallResult{return: nil, vm: vm}
  def load_value(vm, true) when is_vm(vm), do: %CallResult{return: true, vm: vm}
  def load_value(vm, false) when is_vm(vm), do: %CallResult{return: false, vm: vm}
  def load_value(vm, n) when is_vm(vm) and is_number(n), do: %CallResult{return: n, vm: vm}
  def load_value(vm, s) when is_vm(vm) and is_binary(s), do: %CallResult{return: s, vm: vm}
  # referenced values
  def load_value(vm, m) when is_vm(vm) and is_map(m), do: Luex.Table.new(vm, m)
  def load_value(vm, {:userdata, payload}) when is_vm(vm), do: Luex.Userdata.new(vm, payload)
  def load_value(vm, f) when is_vm(vm) and is_function(f, 2), do: Luex.Functions.new(vm, f)

  @doc """

  """
  @spec set_value(lua_call(lua_value()), keypath()) :: vm()
  def set_value(%Luex.CallResult{vm: vm, return: r }, keypath), do: set_value(vm, keypath, r)
  
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

  @spec get_value(vm() | lua_call(any()), keypath()) :: lua_call(lua_value())
  def get_value(%Luex.CallResult{vm: vm}, keypath), do: get_value(vm, keypath)
  def get_value(vm, keypath) when is_vm(vm) and is_list(keypath) do
    Luex.LuaError.wrap do
      get_value1(vm, keypath) |> CallResult.from_luerl()
    end
  end

  # offer private get_value version without wrapping to prevent unnecessary multiple wrapping
  defp get_value1(vm, keypath), do: Luerl.get_table1(vm, keypath)

  @doc """
  create a new lua virtual machine
  """
  @spec init() :: vm()
  defdelegate init, to: Luerl

  @typedoc """
  options 
   - `:ext_searcher`: list of modules that implement Luex.ExtModule, used to extend the lua require function.
  """
  @type vm_config() :: {:lua_ext_searcher, [module()]}

  @spec configure(vm(), [vm_config()]) :: vm()
  def configure(vm, []), do: vm

  def configure(vm, [{:ext_searcher, mods} | args]) do
    whitelist = Enum.map(mods, fn m -> {m.target(), m} end) |> Map.new()

    raw_searcher = fn [query], vm_s when is_lua_string(query) ->
      case Map.get(whitelist, query, :not_found) do
        :not_found ->
          {["no luex module registered for: \"#{query}\""], vm_s}

        ext_module when is_atom(ext_module) ->
          raw_loader = Luex.ExtModule.build_loader(ext_module)
          %CallResult{return: f, vm: vm_s} = Luex.Functions.new(vm_s, raw_loader)
          {[f], vm_s}
      end
    end

    %CallResult{return: searchers, vm: vm} = Luex.get_value(vm, ["package", "searchers"])
    %CallResult{return: epath_searcher, vm: vm} = Luex.Functions.new(vm, raw_searcher)

    vm
    |> Luex.Table.Array.append(searchers, epath_searcher)
    |> configure(args)
  end

  @doc """
  run a string as lua code in the given vm.
  """
  @spec do_inline(vm(), String.t()) :: lua_call([lua_value()])
  def do_inline(vm, program) do
    Luex.LuaError.wrap do
      Luerl.do(vm, program) |> CallResult.from_luerl()
    end
  end

  @doc """
  run the lua file at `path` in the given vm.

  # Example

    ```elixir
    iex> vm0 = Luex.init()
    iex> %Luex.CallResult{return: [5]} = Luex.do_file(vm0, "./test/return_5.lua")
    ```

  """
  @spec do_file(vm(), Path.t()) :: lua_call([lua_value()])
  def do_file(vm, path) do
    Luex.LuaError.wrap do
      Luerl.dofile(vm, to_charlist(path)) |> CallResult.from_luerl()
    end
  end

  # TODO write docs
  @spec do_chunk(vm(), lua_chunk(), [lua_value()]) :: lua_call([lua_value()])
  def do_chunk(vm, chunk, args \\ []) do
    Luex.LuaError.wrap do
      Luerl.call(vm, chunk, args)  |> CallResult.from_luerl()
    end
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
