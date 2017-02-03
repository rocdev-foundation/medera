defmodule Medera.Minion.Registry do
  @moduledoc """
  Runs on the master node and keeps track of connected minions

  Automatically detects minion disconnects and removes them from the list
  """

  alias Medera.Minion.Skill

  defmodule State do
    @moduledoc false
    defstruct([
      minions: MapSet.new,
      invocations: %{}
    ])
  end

  require Logger

  use GenServer

  @doc "Start in a supervision tree"
  @spec start_link() :: GenServer.on_start
  def start_link do
    init_skills = Skill.master_node_skills
    |> Skill.to_map

    GenServer.start_link(
      __MODULE__,
      [init_skills],
      name: {:global, :minion_registry}
    )
  end

  @doc """
  Registers a node

  Returns the pid of the registry for monitoring.  Connection uses this to
  detect disconnects
  """
  @spec register(map) :: pid
  def register(invocations) do
    GenServer.call(
      {:global, :minion_registry},
      {:register, self(), invocations}
    )
  end

  @doc false # see Minion.list
  @spec list_minions() :: [atom]
  def list_minions() do
    GenServer.call({:global, :minion_registry}, :list)
  end

  @doc false # See Minion.list_skills
  @spec list_skills :: [Skill.t]
  def list_skills() do
    GenServer.call({:global, :minion_registry}, :list_skills)
  end

  def init([init_skills]) do
    {:ok, %State{invocations: merge_invocations(%{}, init_skills)}}
  end

  def handle_call({:register, registeree, invocations}, _from, state) do
    Logger.info("Node #{inspect :erlang.node(registeree)} connected")
    Process.monitor(registeree)
    state_out = %{state |
      minions: MapSet.put(state.minions, registeree),
      invocations: merge_invocations(state.invocations, invocations)
    }
    {:reply, self(), state_out}
  end
  def handle_call(:list, _from, state) do
    {:reply, MapSet.to_list(state.minions), state}
  end
  def handle_call(:list_skills, _from, state) do
    {:reply, state.invocations, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    Logger.info("Node #{inspect :erlang.node(pid)} disconnected")
    {:noreply, %{state | minions: MapSet.delete(state.minions, pid)}}
  end

  defp merge_invocations(inv1, inv2) do
    inv2
    |> Enum.reduce(
      inv1,
      fn({inv, skill}, acc_inv) ->
        Map.update(acc_inv, inv, [skill], &merge_skills(&1, skill))
      end
    )
  end

  defp merge_skills(existing, skill) do
    [skill] ++ Enum.reject(existing, fn(e) -> e.node == skill.node end)
  end
end
