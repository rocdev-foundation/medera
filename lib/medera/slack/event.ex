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
  defp event_type(%{type: "message"}), do: :message
  defp event_type(event) do
    Logger.debug("Received unkown event type: #{inspect event}")
    :unknown
  end
end


