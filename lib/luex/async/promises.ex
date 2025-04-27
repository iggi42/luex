defmodule Luex.Async.Promises do
  @behaviour Luex.ExtModule

  def loader(vm), do: vm

  @callback target() :: Luex.lua_string()
end
