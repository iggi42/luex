defmodule Luex.Records.Utils do
  @doc """
    Shorthand for loading records defined in luerl headers.

    Adds a typespec to the code under `@type luerl_\#{name}`, describing the record with typespec.
    Defines a guard under `is_luerl_\#{name}/1` to check whether a value is of the given record type.

    Creates via `Record.defrecord` functions to create and update the record.
    The function to update will be called `luerl_\#{name}/2`.
    The create function will be called `luerl_\#{name}/2`.
  """
  defmacro load_luerl_struct(name, typespec, doc \\ false) when is_atom(name) do
    target = "luerl_#{to_string(name)}"
    type = Macro.var(String.to_atom(target), __MODULE__)
    guard = String.to_atom("is_#{target}")
    quote do
      # TODO check if you can put this in an require hook? 
      require Record
      require Macro

      @doc """
      """
      Record.defrecord(
        unquote(String.to_atom(target)),
        Record.extract(unquote(name), from_lib: "luerl/include/luerl.hrl")
      )
      @typedoc unquote(doc)
      @type unquote(type) :: record(unquote( String.to_atom(target)), unquote(typespec))

      @doc unquote(if doc do 
        quote do: "Check if a value is of the `#{unquote(target)}` type."
      else
        false
      end)
      defguard unquote(guard)(v) when Record.is_record(v, unquote(name))
    end
  end
end

defmodule Luex.Records do
  require __MODULE__.Utils, as: U

  U.load_luerl_struct(:luerl, [
            tabs: any(),
            envs: any(),
            usds: any(),
            fncs: any(),
            g: any(),
            stk: any(),
            cs: any(),
            meta: any(),
            rand: any(),
            tag: any(),
            trace_func: any(),
            trace_data: any()
  ], "this is a luerl vm")

  U.load_luerl_struct(:tstruct, [data: any(), free: any(), next: any()])

end
