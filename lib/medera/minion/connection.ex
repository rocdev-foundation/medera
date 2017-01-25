defmodule Medera.Minion.Connection do
  @moduledoc """
  Connects to the master node and registers this minion

  Automatically detects when the master goes down and reconnects
  """

  # i.e., timeout now
  @no_dwell 0
  # how long to wait after startup to attempt a connection
  @init_dwell 10
  # how long to wait to retry connection
  @connect_dwell 100


  alias Medera.Minion
  alias Medera.Minion.Registry

  require Logger

  use GenServer

  @doc "Start in a supervision tree"
  @spec start_link() :: GenServer.on_start
  def start_link do
    name = "minion-" <> (Node.self() |> Atom.to_string)
    GenServer.start_link(__MODULE__, [], name: {:global, name})
  end

  def init(_) do
    {:ok, :disconnected, @init_dwell}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _}, _state) do
    Logger.info("Detected disconnect from master")
    {:noreply, :disconnected, @connect_dwell}
  end
  def handle_info(:timeout, :disconnected) do
    master = Minion.master_node()
    case Node.connect(master) do
      x when x in [true, :ignored] ->
        Logger.info("Connected to master node #{inspect master}")
        {:noreply, :unregistered, @no_dwell}
      _ ->
        {:noreply, :disconnected, @connect_dwell}
    end
  end
  def handle_info(:timeout, :unregistered) do
    :global.sync
    if :minion_registry in :global.registered_names do
      registry = Registry.register
      Process.monitor(registry)
      Logger.info("Registered with master node #{inspect Minion.master_node()}")
      {:noreply, :connected}
    else
      {:noreply, :unregistered, @connect_dwell}
    end
  end
end
