defmodule Medera.Connector do
  @moduledoc """
  Handles events to/from Slack

  Responsible for forwarding messages to/from the slack connection
  """

  alias Slack.Bot
  alias Slack.Sends
  alias Medera.MessageProducer

  use Slack

  require Logger

  def send_message(text, channel) do
    send(__MODULE__, {:send_message, text, channel})
  end

  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  def handle_event(message = %{type: "message"}, _slack, state) do
    MessageProducer.sync_notify(self(), message)
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:send_message, text, channel}, slack, process_state) do
    Sends.send_message(text, channel, slack)
    {:ok, process_state}
  end
  def handle_info(msg, _slack, process_state) do
    Logger.warn("#{__MODULE__} is ignoring unexpected message #{inspect msg}")
    {:ok, process_state}
  end
end
