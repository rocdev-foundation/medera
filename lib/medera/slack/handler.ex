defmodule Medera.Slack.Handler do
  alias Medera.Slack.Event

  def handle_event(event = %Event{}) do
    event
    |> route_to_handler
    |> maybe_reply
  end

  def handle_message(%Event{text: text, channel: channel, type: :message}) do
    if text && text == "Hi" do
      {:ok, {:reply, "Hello, there!", channel}}
    else
      IO.puts("WTF #{inspect text}")
      :ok
    end
  end

  defp route_to_handler(event = %Event{type: :message}) do
    handle_message(event)
  end
  defp route_to_handler(%Event{}) do
    # unhandled event type - OK for now
    :ok
  end

  defp maybe_reply({:ok, {:reply, text, channel}}) do
    Medera.Slack.send_message(text, channel)
  end
  defp maybe_reply(:ok), do: :ok
  defp maybe_reply({:error, _}) do
    # TODO handle errors
    :ok
  end
end
