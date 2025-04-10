defmodule Luex.Table.NotAnArrayException do
  defexception [:wrong_key, :table]

  @impl Exception
  def message(%{wrong_key: k, table: t}) do
    "lua table is not a well formed array, because of key #{inspect(k)} in table #{inspect(t, pretty: true)}"
  end
end
