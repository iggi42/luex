defmodule Luex.Async.Server do
  use GenServer

  defmodule __MODULE__.State do
    defstruct [:vm]
  end

  alias __MODULE__.State, as: S

  # configure 
  def init(args) do
    do_conf = args[:setup] || (& &1)

    Luex.init()
    |> then(do_conf)
    |> then(&{:ok, %S{vm: &1}})
  end

  def handle_call({:do_inline, inline_lua}, _from, state) do
    {results, vm} = Luex.do_inline(state.vm, inline_lua)
    response = {:ok, results}
    state = %S{ state | vm: vm }
    {:reply, response, state}
  end

end
