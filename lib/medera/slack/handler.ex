defmodule Medera.Slack.Handler do
  alias Medera.Slack.Event

  def handle_event(event = %Event{}) do
    case event do
      %Event{type: :message} -> handle_message(event)
      _ -> :ok  # unhandled event type - ok for now
    end
  end

  def handle_message(%Event{text: text, channel: channel, type: :message}) do
    if text && text == "Hi" do
      {:ok, {:reply, "Hello, there!", channel}}
    else
      :ok
    end
  end
end
