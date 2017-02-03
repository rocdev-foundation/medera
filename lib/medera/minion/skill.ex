defmodule Medera.Minion.Skill do
  @moduledoc """
  Represents an action that a minion can take on behalf of the master node

  Skills can be stored in a file as a JSON array.  Each skill in the file must
  contain a description, a verb, a noun, and a command.

  Each node also gets a set of "intrinsic" skills that are common to all nodes.
  See `intrinsic_skills/0`.

  The master node also gets a list of skills that are only available in the
  master context.  See `master_node_skills/0`

  Each skill has an "invocation" - a string command.  The invocation is formed
  by concatenating "<verb>-<noun>" - e.g., "ls-/" if the verb is "ls" and the
  noun is "/".
  """

  # gives us json encoding/decoding
  @derive [Poison.Encoder]

  defstruct([
    description: nil,
    verb: nil,
    noun: nil,
    command: nil,
    node_required: true,
    node: nil
  ])
  @type t :: %__MODULE__{}

  alias Medera.Minion
  alias Medera.Minion.Skill

  @doc "Default path where skills are loaded (set in config)"
  @spec default_path :: binary | nil
  def default_path do
    Application.get_env(:medera, :minion_skills)
  end

  @doc """
  Load intrinsic skills and skills from a file

  If path is nil, only `intrinsic_skills/0` are used.  Otherwise, the path
  is expected to contain a JSON array of encoded skills.

  Sets the skill node to be this node (i.e., the node doing the loading)
  """
  @spec load!(nil | binary) :: [t]
  def load!(nil) do
    intrinsic_skills()
    |> Enum.map(fn(skill) -> %{skill | node: Node.self()} end)
  end
  def load!(path) do
    path
    |> File.read!
    |> Poison.decode!(as: [%Skill{}])
    |> Enum.concat(intrinsic_skills())
    |> Enum.map(fn(skill) -> %{skill | node: Node.self()} end)
  end

  @doc """
  Load skills from the default path, return an invocation to skill map
  """
  @spec load_map! :: map
  def load_map! do
    load_map!(default_path())
  end

  @doc """
  Load skills from the given path, return an invocation to skill map
  """
  @spec load_map!(binary | nil) :: map
  def load_map!(path) do
    path
    |> load!
    |> to_map
  end

  @doc """
  Returns the invocation string for the given skill

  This is equal to "<verb>-<noun>"
  """
  @spec invocation(t) :: binary
  def invocation(skill = %Skill{}) do
    skill.verb <> "-" <> skill.noun
  end

  @doc """
  Skills that the master node has but normal nodes do not
  """
  @spec master_node_skills :: [t]
  def master_node_skills do
    [
      %Skill{
        description: "List minions",
        verb: "list",
        noun: "minions",
        node_required: false,
        node: Node.self(),
        command: fn -> Minion.list() end
      }
    ]
  end

  @doc """
  Skills that each node has regardless of configuration
  """
  @spec intrinsic_skills :: [t]
  def intrinsic_skills do
    [
      %Skill{
        description: "List minion skills",
        verb: "list",
        noun: "skills",
        command: fn -> Minion.list_skills() end
      },
      %Skill{
        description: "Get some basic info about the minion",
        verb: "get",
        noun: "minion-info",
        command: fn -> Minion.info() end
      }
    ]
  end

  @doc """
  Convert a list of skills to an `invocation => skill` map
  """
  @spec to_map([t]) :: map
  def to_map(skills) do
    skills
    |> Enum.map(fn(skill) -> {invocation(skill), skill} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns true if the given node name (string) is valid for the given skill
  """
  @spec valid_node?(t, binary) :: boolean
  def valid_node?(%Skill{node: skill_node}, node_string)
  when is_binary(node_string) do
    Atom.to_string(skill_node) == node_string
  end
end
