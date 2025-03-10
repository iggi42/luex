defmodule Mix.Tasks.Luex do
  use Mix.Task

  @impl Mix.Task
  def run(argv) do
    argv
    |> OptionParser.parse(
      aliases: [
        e: :eval,
        h: :help,
        i: :interactive
      ],
      strict: [
        eval: :string,
        help: :boolean,
        interactive: :boolean
      ]
    )
    |> execute()
  end

  defp execute({_, _, errors}) when errors != [],
    do: useage(:stderr)

  defp execute({args, [], []}) do
    cond do
      Keyword.get(args, :help) ->
        useage(:stdio)

      Keyword.has_key?(args, :eval) ->
        args
        |> Keyword.get(:eval)
        |> do_file()
    end
  end

  defp do_file(run_me) do
    vm = Luex.init()

    case Luerl.evalfile(vm, to_charlist(run_me)) do
      {:ok, result} ->
        IO.puts("result: #{inspect(result, pretty: true)}")

      {:error, warn, error} ->
        IO.puts("execution failed")
        IO.puts("warnings: #{inspect(warn, pretty: true)}\n")
        IO.puts("errors: #{inspect(error, pretty: true)}\n")
    end
  end

  defp useage(device) do
    IO.puts(device, """
      useage help
      todo :)
    """)
  end
end
