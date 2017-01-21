defmodule Medera.Minion.Registry do
  @moduledoc """
  Runs on the master node and keeps track of connected minions

  Automatically detects minion disconnects and removes them from the list
  """

  defmodule State do
    @moduledoc false
    defstruct(minions: MapSet.new)
  end

  require Logger

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :minion_registry})
  end

  def register() do
    GenServer.call({:global, :minion_registry}, {:register, self()})
  end

  def list_minions() do
    GenServer.call({:global, :minion_registry}, :list)
  end

  def init([]) do
    {:ok, %State{}}
  end

  def handle_call({:register, registeree}, _from, state) do
    Logger.info("Node #{inspect :erlang.node(registeree)} connected")
    Process.monitor(registeree)
    {:reply, self(), %{state | minions: MapSet.put(state.minions, registeree)}}
  end
  def handle_call(:list, _from, state) do
    {:reply, MapSet.to_list(state.minions), state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    Logger.info("Node #{inspect :erlang.node(pid)} disconnected")
    {:noreply, %{state | minions: MapSet.delete(state.minions, pid)}}
  end
end
