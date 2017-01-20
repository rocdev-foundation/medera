defmodule Medera.Minion do
  require Logger

  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Phoenix.PubSub.PG2, [Medera.Minion.PubSub, []]),
      worker(Medera.Minion.Listener, [])
    ]
    opts = [strategy: :one_for_one, name: Medera.Minion.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    register()

    {:ok, pid}
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(Medera.Minion.PubSub, topic, message)
  end

  def register do
    master = master_node()
    Logger.info("Connecting to master node #{inspect master}")
    case Node.connect(master_node()) do
      true -> Logger.info("Success.")
      :ignored -> Logger.info("Success (this is the master node).")
      other -> Logger.warn("Node connection failed: #{inspect other}")
    end
  end

  def master_node do
    case Application.get_env(:medera, :master_node) do
      name when is_binary(name) -> String.to_atom(name)
      nil -> Node.self()
    end
  end
end
