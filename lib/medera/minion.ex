defmodule Medera.Minion do
  @moduledoc """
  A Medera Minion is a worker node available to the Medera server
  """

  alias Medera.Minion.Registry
  alias Medera.Minion.Skill

  require Logger

  @doc "Returns a list of minion nodes"
  @spec list() :: [atom]
  def list do
    Registry.list_minions |> Enum.map(&:erlang.node/1)
  end

  @doc "Returns info about the minion"
  @spec info :: binary
  def info() do
    "Hi, I am #{inspect Node.self()}."
  end

  @doc "Returns a list of skills for all minions"
  @spec list_skills :: [Skill.t]
  def list_skills() do
    Registry.list_skills()
  end

  @doc """
  Dispatch a skill to the appropriate minion

  This makes a remote call to the node that owns the skill
  """
  @spec dispatch(Skill.t) :: term
  def dispatch(skill = %Skill{}) do
    # probably eventually want to use distributed tasks or something like that
    # here (or even a worker pool)
    :rpc.call(skill.node, Medera.Minion, :dispatch_local, [skill])
  end

  @doc """
  Executes the given skill on this minion node
  """
  @spec dispatch_local(Skill.t) :: term
  def dispatch_local(skill = %Skill{}) do
    case skill.command do
      command when is_binary(command) ->
        command
        |> String.to_charlist
        |> :os.cmd
        |> List.to_string
      f when is_function(f, 0) ->
        f.()
    end
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
