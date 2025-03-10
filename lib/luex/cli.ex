defmodule Luex.Cli do
  defmodule Options do
    @typedoc """
    The result of parsed command line arguments.

    - **interactive**: Test
    """
    @type t() :: %__MODULE__{
            interactive: boolean(),
            execute: [String.t()],
            library: [String.t()],
            show_version: boolean(),
            ignore_env: boolean(),
            script: :stdin | Path.t() | nil
          }

    defstruct interactive: false,
              execute: [],
              library: [],
              show_version: false,
              ignore_env: false,
              script: :stdin
  end

  @doc """
  Parse command line arguments from the mix task to the #{__MODULE__}.Options struct.
  """
  @spec parse_arg(argv :: [String.t()]) ::
          {[__MODULE__.Options.t()], script_parameter :: [String.t()]}
  def parse_arg(_argv), do: throw(:not_implemented)
end
