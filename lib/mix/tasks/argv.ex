defmodule Mix.Tasks.Argv do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.argv()
    |> inspect(pretty: true)
    |> IO.puts()
  end
end
