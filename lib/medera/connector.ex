defmodule Medera.Connector do
  @moduledoc """
  Handles events to/from Slack

  Responsible for forwarding messages to/from the slack connection
  """

  alias Slack.Bot
  alias Slack.Sends
  alias Medera.MessageProducer

  use Slack

  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    MessageProducer.sync_notify(self(), {message, slack})
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def send_message(text, channel, slack) do
    Sends.send_message(text, channel, slack)
  end
end
