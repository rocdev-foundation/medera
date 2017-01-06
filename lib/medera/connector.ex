defmodule Medera.Connector do
  @moduledoc """
  Handles events to/from Slack

  Responsible for forwarding messages to/from the slack connection
  """

  alias Slack.Bot
  alias Slack.Sends
  alias Medera.SlackEventHandler

  use Slack

  require Logger

  def send_message(text, channel) do
    send(__MODULE__, {:send_message, text, channel})
  end

  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  def handle_event(message, slack, state) do
    case SlackEventHandler.handle_event(message) do
      {:reply, channel, reply_msg} -> Sends.send_message(reply_msg, channel, slack)
      :noreply -> :ok
    end
    {:ok, state}
  end

  def handle_info({:send_message, text, channel}, slack, process_state) do
    Sends.send_message(text, channel, slack)
    {:ok, process_state}
  end
  def handle_info(msg, _slack, process_state) do
    Logger.warn("#{__MODULE__} is ignoring unexpected message #{inspect msg}")
    {:ok, process_state}
  end
end
