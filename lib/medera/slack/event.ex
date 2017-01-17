defmodule Medera.Slack.Event do
  @moduledoc """
  Represents an event we receive from Slack

  An Event struct always contains the original payload from Slack in the
  payload field.  Some fields are "promoted" to the top level of the struct
  if they are present:
  
  * `type` - The event type
  * `user` - Slack user id
  * `channel` - Slack channel id (may be a direct message)
  * `payload` - The original struct recieved

  The following fields may be prepopulated if they were available and
  applicable:
  * `human_user` - Human-readable user name
  * `human_channel` - Human-readable channel
  * `direct_message` - `true` if the event was a direct message
  """

  require Logger

  defstruct(
    type: nil,
    user: nil,
    human_user: nil,
    channel: nil,
    human_channel: nil,
    direct_message: false,
    payload: nil
  )
  @type t :: %__MODULE__{}

  alias __MODULE__

  @doc """
  Convert from the bare map we get from the slack bot

  `extra` contains extra lookup data that was not part of the original payload
  """
  @spec from_slack(map, map) :: t
  def from_slack(event, extra) do
    %Event{
      type: Map.get(event, :type),
      direct_message: Map.get(extra, :direct_message, false),
      # these might not be set, so use Map.get which will safely set them to
      # nil if they are not present
      channel: Map.get(event, :channel),
      human_channel: Map.get(extra, :channel),
      user: Map.get(event, :user),
      human_user: Map.get(extra, :human_user),
      payload: event
    }
  end
end

