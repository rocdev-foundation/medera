defmodule Medera.Slack.HandlerTest do
  # handler module unit tests

  use ExUnit.Case

  alias Medera.Slack.Event

  defdelegate event(payload, extra \\ %{}), to: Event, as: :from_slack

  test "replies to 'Hi'" do
    channel = "#test"
    message = event(%{text: "Hi", type: "message", channel: channel})
    assert {:ok, {:reply, _, ^channel}} =
      Medera.Slack.Handler.handle_event(message)
  end

  test "tells us the minion names" do
    :ok = Patiently.wait_for(fn -> :minion@localhost in Medera.Minion.list end)
    channel = "#test"
    message = event(%{text: "!list-minions", type: "message", channel: channel})
    assert {:ok, {:reply, "[:minion@localhost, :medera@localhost]", channel}} ==
      Medera.Slack.Handler.handle_event(message)
  end
end
