defmodule Medera.Slack.Connector do
  @moduledoc """
  Interface with Slack bot.

  Do NOT use this module directly!  It is very untestable.  The public API is
  intentionally very restricted.  Use Medera.Slack for Slack interaction.
  """

  alias Slack.Bot
  alias Slack.Sends
  alias Slack.Lookups

  use Slack

  alias Medera.Slack, as: MederaSlack

  require Logger

  @doc false
  @spec start_link(binary) :: GenServer.on_start
  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  @doc false
  def handle_event(event, slack, state) do
    :ok = event
    |> resolve_user(slack)
    |> resolve_channel(slack)
    |> MederaSlack.receive_event

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

  # `:user` is a slack id - this resolves that to a human-readable
  #    user id if one is available
  defp resolve_user(event = %{user: user}, slack) do
    Map.put(event, :human_user, Lookups.lookup_user_name(user, slack))
  end
  defp resolve_user(event, _), do: event

  # `:channel` is a slack id - this resolves that to a human-readable
  #    channel name if one is available and marks the message as a DM if it is
  defp resolve_channel(event = %{channel: channel}, slack) do
    case channel do
      # channel
      "C" <> _ ->
        Map.put(
          event,
          :human_channel,
          Lookups.lookup_channel_name(channel, slack)
        )
      # direct message
      "D" <> _ ->
        event
        |> Map.put(:human_channel, Lookups.lookup_user_name(channel, slack))
        |> Map.put(:direct_message, true)
    end
  end
  defp resolve_channel(event, _), do: event

end
