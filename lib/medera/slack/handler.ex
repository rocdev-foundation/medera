defmodule Medera.Slack.Handler do
  @moduledoc """
  Main slack event handler workhorse

  See `handle_event/1`
  """

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
    %Event{
      channel: channel,
      type: "message",
      payload: %{text: text}
    }
  ) do
    if text && text == "Hi" do
      {:ok, {:reply, "Hello, there!", channel}}
    else
      :ok
    end
  end
end
