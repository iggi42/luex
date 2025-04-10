defmodule Luex.Table.RecursiveException do
  defexception [:path, :current]

  @impl Exception
  def message(%{path: p, current: c}) do
    "lua table is recursive at #{inspect(c)} with keypath #{inspect(p, pretty: true)}"
  end
end
