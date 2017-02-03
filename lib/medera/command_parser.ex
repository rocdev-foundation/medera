defmodule Medera.CommandParser do
  @moduledoc """
  Parses a command and resolves it against the registry of skills
  """

  alias Medera.Minion.Skill
  alias Medera.Slack.Event

  @type error_t :: :no_node | {:invalid_node, Skill.t}

  @doc """
  Parse the given text and resolve it against the given list of skills,
  returning a matching skill on success.
  """
  @spec parse_command(binary, Event.t, [Skill.t]) ::
  {:ok, Skill.t} | {:error, error_t}
  def parse_command(text, _event = %Event{}, skills) do
    [command | remainder] = String.split(text)
    parse_command_arguments(Map.get(skills, command), remainder)
  end

  defp parse_command_arguments(nil, _), do: {:error, :no_match}
  defp parse_command_arguments([skill], args) do
    if skill.node_required do
      case args do
        [] -> {:error, :no_node}
        [node | _other_args] ->
          if Skill.valid_node?(skill, node) do
            {:ok, skill}
          else
            {:error, {:invalid_node, skill}}
          end
      end
    else
      {:ok, skill}
    end
  end
  defp parse_command_arguments(_matching_skills, []) do
    # if more than one skill matched, the skill is on more than one node,
    # but we didn't provide a node, so there's no matching node
    {:error, :no_node}
  end
  defp parse_command_arguments(matching_skills, [node | _other_args]) do
    matching_skill = matching_skills
    |> Enum.find(fn(skill) -> Skill.valid_node?(skill, node) end)

    if matching_skill do
      {:ok, matching_skill}
    else
      {:error, :no_node}
    end
  end
end
