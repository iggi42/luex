defmodule Luex.Async.Server do
  use GenServer

  def init(args) do
    vm = Luex.init(args)
    {:ok, {:state, vm, []}}
  end

  def handle_call({:do_inline}, from, state) do
  end
end
