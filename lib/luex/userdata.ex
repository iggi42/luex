defmodule Luex.Userdata do
  # TODO implement the Enumerable protocol against lua tables.

  require Luex
  require Luex.Records

  alias Luex.CallResult, as: LCall

  @type t() :: Luex.Records.usdref()

  @doc """
  allocate a new userdata in the virtual machine
  """
  @spec new(Luex.vm(), payload :: any()) :: Luex.lua_call(t())
  def new(vm, payload) when Luex.is_vm(vm) do
    :luerl_heap.alloc_userdata(payload, vm) |> LCall.from_luerl()
  end

  @spec get_data(Luex.lua_call(t())) :: Luex.lua_call(payload :: any())
  def get_data(%LCall{vm: vm, return: uref}) when Luex.Records.is_userdata(uref) do
    get_data(vm, uref)
  end


  @spec get_data(Luex.vm(), t()) :: Luex.lua_call(payload :: any())
  def get_data(vm, uref) when Luex.is_vm(vm) do
    {val, vm} = :luerl_heap.get_userdata(uref, vm)
    %LCall{
      return: Luex.Records.userdata(val, :d),
      vm: vm
    }
  end

  # not sure if this trend is going well
  @spec set_data(Luex.lua_call(any()), t(), payload :: any()) :: Luex.vm()
  def set_data(%Luex.CallResult{vm: vm, return: uref}, payload), do: set_data(vm, uref, payload)

  @spec set_data(Luex.vm(), t(), payload :: any()) :: Luex.vm()
  def set_data(vm, uref, payload) do
    :luerl_heap.set_userdata_data(uref, payload, vm)
  end
end
