defmodule Luex.Records.Utils do
  require Logger

  @doc """
    Shorthand for loading records defined in luerl headers.

    Adds a typespec to the code under `@type \#{name}`, describing the record with typespec.
    Defines a guard under `is_\#{name}/1` to check whether a value is of the given record type.

    Creates via `Record.defrecord` functions to create and update the record.
    The function to update will be called `\#{name}/2`.
    The create function will be called `\#{name}/2`.
  """
  defmacro load_luerl_struct(name, desc, overwrite_type \\ %{}) when is_atom(name) do
    type = Macro.var(name, __MODULE__)
    guard = String.to_atom("is_#{name}")
    record = Record.extract(name, from_lib: "luerl/include/luerl.hrl")

    record_spec =
      Enum.map(record, fn
        {k, _} ->
          m = overwrite_type[k]
          v = if m, do: m, else: quote(do: any())
          {k, v}
      end)

    quote do
      # TODO check if you can put this in an require hook? 
      require Record
      require Macro

      @doc """
      creates a record of #{unquote(name)}
      """
      Record.defrecord(unquote(name), unquote(record))

      @typedoc unquote(desc)
      @type unquote(type) :: record(unquote(name), unquote(record_spec))

      @doc "Check if a value is of the `#{unquote(name)}` type."
      defguard unquote(guard)(v) when Record.is_record(v, unquote(name))
    end
  end
end
