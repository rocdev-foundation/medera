defmodule SlackIngestor.Connector do
  @moduledoc ""
  alias Slack.Bot
  alias SlackIngestor.MessageProducer

  use Slack

  def start_link(token) do
    Bot.start_link(__MODULE__, [], token, %{name: __MODULE__})
  end

  def respond_to({message, slack}) do
    if message.text == "Hi" do
      send_message("Hello to you, too!", message.channel, slack)
    end
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    MessageProducer.sync_notify(self(), {message, slack})
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}
end
