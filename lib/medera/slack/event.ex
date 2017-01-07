defmodule Medera.Slack.Event do
  @moduledoc """
  Represents an event we receive from Slack
  """

  require Logger

  defstruct(
    type: nil,
    text: nil,
    ts: nil,
    user: nil,
    channel: nil
  )
  @type t :: %__MODULE__{}

  alias __MODULE__

  @doc """
  Convert from the bare map we get from the slack bot
  """
  @spec from_slack(map) :: t
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

  # determine the event type
  defp event_type(%{type: "message"}),         do: :message
  # sent when we first connect
  defp event_type(%{type: "hello"}),           do: :hello
  # when a user is setting/unsetting 'away'
  defp event_type(%{type: "presence_change"}), do: :presence_change
  # experimental: http://api.slack.com/events/reconnect_url
  defp event_type(%{type: "reconnect_url"}),   do: :reconnect_url
  defp event_type(event) do
    Logger.debug("Received unkown type of event: #{inspect event}")
    :unknown
  end
end


