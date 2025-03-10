defmodule Mix.Tasks.Echo do
  use Mix.Task

  @impl Mix.Task
  def run(input) do
    input
    |> inspect(pretty: true)
    |> IO.puts()
  end
end
