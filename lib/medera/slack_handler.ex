defmodule Medera.SlackHandler do
  @moduledoc """
  Handles events from Slack

  In dev/prod, events come from the Slack connection established in
  Medera.Connector.

  In test, events come from Medera.Support.TestConnector
  """

  alias Medera.MessageProducer

  use Slack

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
