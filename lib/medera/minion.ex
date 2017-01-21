defmodule Medera.Minion do
  @moduledoc """
  A Medera Minion is a worker node available to the Medera server
  """

  alias Medera.Minion.Registry

  @doc "Returns a list of minion nodes"
  @spec list() :: [atom]
  def list do
    Registry.list_minions |> Enum.map(&:erlang.node/1)
  end

  @doc "Returns the configured master node"
  @spec master_node :: atom
  def master_node do
    case Application.get_env(:medera, :master_node) do
      name when is_binary(name) -> String.to_atom(name)
      nil -> Node.self()
    end
  end
end
