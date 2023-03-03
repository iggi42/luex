defmodule Mix.Tasks.Luex do
  use Mix.Task

  def run([run_me]) do
    case do_file(run_me) do
      {:ok, result} ->
        IO.puts("result")
        result |> inspect(pretty: true) |> IO.puts()

      {:error, warn, error} ->
        IO.puts("execution failed")
        IO.puts("")
        IO.puts("warnings")
        warn |> inspect(pretty: true) |> IO.puts()
        IO.puts("")
        IO.puts("errors")
        error |> inspect(pretty: true) |> IO.puts()
    end
  end

  defp do_file(path) do
    Luerl.init()
    |> Luerl.evalfile(to_charlist(path))
  end
end
