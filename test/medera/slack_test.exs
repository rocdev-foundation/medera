defmodule Medera.SlackTest do
  # slack integration tests

  use ExUnit.Case

  alias Medera.Support.TestConnector

  setup do
    TestConnector.flush_sent_messages
    on_exit fn -> TestConnector.flush_sent_messages end
  end

  test "receiving and immediately replying to a message" do
    assert :ok == Medera.Slack.receive_event(
      %{type: "message", channel: "#inttest", text: "Hi"}
    )
    assert [{_, "#inttest"}] = TestConnector.await_sent_messages(1)
  end

  test "receiving a message that has no reply" do
    assert :ok == Medera.Slack.receive_event(
      %{type: "message", channel: "#intttest", text: "IGNORE ME"}
    )
    assert [] == TestConnector.sent_messages()
  end

  test "receiving an unknown event type" do
    assert :ok == Medera.Slack.receive_event(
      %{type: "butts"}
    )
    assert [] == TestConnector.sent_messages()
  end

  test "sending a message" do
    assert :ok == Medera.Slack.send_message("Hello", "#some_channel")
    assert [{"Hello", "#some_channel"}] = TestConnector.await_sent_messages(1)
  end

  test "receiving a message to which the handler responds with an error" do
    assert :ok == Medera.Slack.receive_event(
      %{type: "message", channel: "#intttest", text: "I am Error"}
    )
  end
end
