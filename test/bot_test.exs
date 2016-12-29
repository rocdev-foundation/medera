defmodule Medera.BotTest do
  # high-level bot tests

  alias Medera.Support.TestConnector

  use ExUnit.Case

  setup do
    TestConnector.flush_sent_messages

    on_exit fn ->
      TestConnector.flush_sent_messages
    end
  end

  test "responds to 'Hi' by sending a message back" do
    TestConnector.receive_message("Hi", "#test")
    [sent_message] = TestConnector.await_sent_messages(1)
    assert "#test" == sent_message.channel
    assert "message" == sent_message.type
  end
end
