defmodule Luex.Async.Promises do
  @moduledoc false
  @behaviour Luex.ExtModule

  def loader(vm), do: vm

  @callback target() :: Luex.lua_string()
end
