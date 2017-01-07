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
      # these might not be set, so use Map.get which will safely set them to
      # nil if they are not present
      channel: Map.get(event, :channel),
      text: Map.get(event, :text),
      ts: Map.get(event, :ts),
      user: Map.get(event, :user)
    }
  end

  defp event_type(%{type: "message"}), do: :message
  defp event_type(event) do
    Logger.debug("Received unkown event type: #{inspect event}")
    :unknown
  end
end


