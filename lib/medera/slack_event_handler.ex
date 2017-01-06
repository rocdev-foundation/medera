defmodule Medera.SlackEventHandler do
  def handle_event(message = %{type: "message"}) do
    if message.text && message.text == "Hi" do
      {:reply, message.channel, "Hello, there!"}
    else
      :noreply
    end
  end
  def handle_event(_), do: :noreply
end
