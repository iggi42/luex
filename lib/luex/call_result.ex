defmodule Luex.CallResult do
  @moduledoc false
  # IDEA STAGE: replace the lua(call) type
  # implement enumerable against this
  defstruct [:vm, :return]


  def from_luerl({result, vm}), do: %__MODULE__{vm: vm, return: result}


  def then_vm(%__MODULE__{vm: vm}, fun), do: fun.(vm)

  # def then_result(%__MODULE__{result: r}, fun), do: fun.(r)
  # is a bad idea, because users might throw away a vm state and use an old instead

end
