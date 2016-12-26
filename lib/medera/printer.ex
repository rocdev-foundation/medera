defmodule Medera.Printer do
  @moduledoc ""
  alias Experimental.GenStage
  alias Medera.SlackHandler

  use GenStage

  @doc "Starts the consumer."
  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Medera.MessageProducer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      SlackHandler.respond_to(event)
    end
    {:noreply, [], state}
  end
end
