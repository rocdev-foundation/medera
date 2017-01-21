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

  @doc "Start in a supervision tree"
  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, :minion_registry})
  end

  @doc """
  Registers a node

  Returns the pid of the registry for monitoring.  Connection uses this to
  detect disconnects
  """
  @spec register() :: pid
  def register() do
    GenServer.call({:global, :minion_registry}, {:register, self()})
  end

  @doc false # see Minion.list
  @spec list_minions() :: [atom]
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
