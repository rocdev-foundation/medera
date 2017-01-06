defmodule Medera.SlackEventHandlerTest do
  use ExUnit.Case

  alias Medera.SlackEventHandler

  test "replies to 'Hi'" do
    channel = "#test"
    message = %{text: "Hi", channel: channel, type: "message"}
    assert {:reply, ^channel, _} = SlackEventHandler.handle_event(message)
  end
end
