defmodule Medera.Printer do
  @moduledoc ""
  alias Experimental.GenStage

  use GenStage

  @doc "Starts the consumer."
  def start_link(connector) do
    GenStage.start_link(__MODULE__, [connector])
  end

  def init([connector]) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, connector, subscribe_to: [Medera.MessageProducer]}
  end

  # this ought to go somewhere else
  def respond_to(message, connector) do
    if message.text == "Hi" do
      connector.send_message("Hello to you, too!", message.channel)
    end
  end

  def handle_events(events, _from, connector) do
    for event <- events do
      respond_to(event, connector)
    end
    {:noreply, [], connector}
  end
end
