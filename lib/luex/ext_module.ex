defmodule Luex.ExtModule do
  @callback install(Luex.lua_vm()) :: {}
end
