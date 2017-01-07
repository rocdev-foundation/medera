defmodule Medera.Slack.Connector do
  @moduledoc """
  Interface with Slack bot.

  Do NOT use this module directly!  It is very untestable.  The public API is
  intentionally very restricted.  Use Medera.Slack for Slack interaction.
  """

  alias Slack.Bot
  alias Slack.Sends

  use Slack

  require Logger

  @doc false
  @spec start_link(binary) :: GenServer.on_start
  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  @doc false
  def handle_event(event, _slack, state) do
    :ok = Medera.Slack.receive_event(event)
    {:ok, state}
  end

  @doc false
  def handle_info({:send_message, text, channel}, slack, process_state) do
    Sends.send_message(text, channel, slack)
    {:ok, process_state}
  end
  def handle_info(msg, _slack, process_state) do
    Logger.warn("#{__MODULE__} is ignoring unexpected message #{inspect msg}")
    {:ok, process_state}
  end
end
