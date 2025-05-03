defmodule Luex.Async do
  @moduledoc false 

  @typedoc """
  # config options
   - `:boot_args` : map function of lua vm to configure said vm on server start
  """
  @type boot_args() :: [config: (Luex.vm() -> Luex.vm())]

  @type t() :: pid()

  @spec start_link(boot_args(), GenServer.options()) :: GenServer.on_start()
  def start_link(args, options \\ []) do
    GenServer.start_link(__MODULE__.Server, args, options)
  end

  @spec do_inline(t(), String.t(), timeout()) :: {:ok, [Luex.lua_value()]}
  def do_inline(vm, lua, timeout \\ 5000), do: GenServer.call(vm, {:do_inline, lua}, timeout)

end
