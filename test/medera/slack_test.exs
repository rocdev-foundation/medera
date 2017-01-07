defmodule Medera.SlackTest do
  use ExUnit.Case

  alias Medera.Slack.Event

  test "replies to 'Hi'" do
    channel = "#test"
    message = %Event{text: "Hi", channel: channel, type: :message}
    assert :ok == Medera.Slack.Handler.handle_event(message)
    assert {:ok, {:reply, _, ^channel}} = Medera.Slack.Handler.handle_message(message)
  end
end
