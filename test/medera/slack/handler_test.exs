defmodule Medera.Slack.HandlerTest do
  # handler module unit tests

  use ExUnit.Case

  alias Medera.Slack.Event

  test "replies to 'Hi'" do
    channel = "#test"
    message = %Event{text: "Hi", channel: channel, type: :message}
    assert {:ok, {:reply, _, ^channel}} =
      Medera.Slack.Handler.handle_event(message)
  end
end
