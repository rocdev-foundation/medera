defmodule Medera.Minion.Supervisor do
  @moduledoc false

  use Supervisor

  alias Medera.Minion
  alias Medera.Minion.Connection
  alias Medera.Minion.Registry

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = child_specs(Minion.master_node() == Node.self())

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  def child_specs(true) do
    [worker(Connection, []), worker(Registry, [])]
  end
  def child_specs(false) do
    [worker(Connection, [])]
  end
end
