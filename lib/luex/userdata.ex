defmodule Luex.Userdata do
  # TODO implement the Enumerable protocol against lua tables.

  require Luex
  require Luex.Records

  @type t() :: Luex.Records.usdref()

  @doc """
  allocate a new userdata in the virtual machine
  """
  @spec new(Luex.vm(), payload :: any()) :: {t(), Luex.vm()}
  def new(vm, payload) when Luex.is_vm(vm) do
    :luerl_heap.alloc_userdata(payload, vm)
  end

  @spec get_data(Luex.vm(), t()) :: {payload :: any(), Luex.vm()}
  def get_data(vm, uref) when Luex.is_vm(vm) do
    case :luerl_heap.get_userdata(uref, vm) do
      {v, vm1} when Luex.Records.is_userdata(v) -> {Luex.Records.userdata(v, :d), vm1}
    end
  end
end
