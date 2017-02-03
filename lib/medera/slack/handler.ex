defmodule Medera.Slack.Handler do
  @moduledoc """
  Main slack event handler workhorse

  See `handle_event/1`
  """

  alias Medera.CommandParser
  alias Medera.Minion
  alias Medera.Minion.Skill
  alias Medera.Slack.Event

  @typedoc """
  A return value from `handle_event/1`

  * `{:ok, {:reply, text, channel}}` - Message `channel` with
      `text`.  This should be favored for immediate responses.
  * `{:error, error}` - Logs `error`.  No message is sent.
  * `:ok` - Adapter takes no action.

  More options can be added here in the future - they should be implemented
  in `Medera.Slack.handle_event_side_effects/3`
  """
  @type return_t :: :ok | {:error, term} | {:ok, {:reply, binary, binary}}

  @doc """
  Does what it says on the tin.

  This is the main entry point into our business logic for an event coming
  from slack.  This should route the event to the appropriate handler and
  its reply value should tell the slack adapter (Medera.Slack) if and how
  it should react to the message.

  If a message is to be sent back to the user immediately, it is strongly
  recommended that you return `{:ok, {:reply, text, channel}}` - this allows
  for functional testing by isolating side effects to the adapter module.
  See `return_t` for other possible return values.
  """
  @spec handle_event(Event.t) :: return_t
  def handle_event(event = %Event{}) do
    case event do
      %Event{type: "message"} -> handle_message(event)
      _ -> :ok  # unhandled event type - ok for now
    end
  end

  defp handle_message(
    event = %Event{
      type: "message",
      payload: %{text: text}
    }
  ) do
    case text do
      "Hi" -> reply_channel("Hello, there!", event)
      "I am Error" -> {:error, "This is an error test"}
      "!" <> text -> handle_command(text, event)
      _ -> :ok
     end
  end

  defp handle_command(command, event) do
    case CommandParser.parse_command(command, event, Minion.list_skills()) do
      {:error, :no_match} -> {:error, "No matching command '#{command}'"}
      {:error, :no_node} -> {:error, "Must specify a node for '#{command}'"}
      {:error, {:invalid_node, skill}} ->
      {:error, "Invalid node for '#{Skill.invocation(skill)}'"}
      {:ok, skill} -> reply_channel(Minion.dispatch(skill), event)
    end
  end

  defp reply_channel(message, event) when is_binary(message) do
    {:ok, {:reply, message, event.channel}}
  end
  defp reply_channel(message, event) do
    reply_channel(inspect(message), event)
  end
end
