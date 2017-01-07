defmodule Medera.Slack.Event do
  require Logger

  defstruct(
    type: nil,
    text: nil,
    ts: nil,
    user: nil,
    channel: nil
  )

  alias __MODULE__

  def from_slack(event) do
    %Event{
      type: event_type(event),
      ts: event.ts,
      user: event.user,
      channel: event.channel,
      text: event.text
    }
  end

  defp event_type(%{type: "message"}), do: :message
  defp event_type(event) do
    Logger.debug("Received unkown event type: #{inspect event}")
    :unknown
  end
end


