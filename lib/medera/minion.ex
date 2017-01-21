defmodule Medera.Minion do
  @moduledoc """
  A Medera Minion is a worker node available to the Medera server
  """

  alias Medera.Minion.Registry
  alias Medera.Minion.Connection

  require Logger

  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      worker(Connection, [])
    ]

    children = if master_node() == Node.self() do
      children ++ [worker(Registry, [])]
    else
      children
    end

    opts = [strategy: :one_for_one, name: Medera.Minion.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    {:ok, pid}
  end

  def list do
    Registry.list_minions |> Enum.map(&:erlang.node/1)
  end

  def master_node do
    case Application.get_env(:medera, :master_node) do
      name when is_binary(name) -> String.to_atom(name)
      nil -> Node.self()
    end
  end
end
