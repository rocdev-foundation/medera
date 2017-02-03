defmodule HandlerTest do
  # handler module unit tests

  use ExUnit.Case

  alias Medera.Slack.Event
  alias Medera.Slack.Handler

  defdelegate event(payload, extra \\ %{}), to: Event, as: :from_slack

  def channel_reply(text, channel) do
    {:ok, {:reply, text, channel}}
  end

  test "replies to 'Hi'" do
    channel = "#test"
    message = event(%{text: "Hi", type: "message", channel: channel})
    assert {:ok, {:reply, _, ^channel}} =
      Handler.handle_event(message)
  end

  test "tells us the minion names" do
    :ok = Patiently.wait_for(fn -> :minion@localhost in Medera.Minion.list end)
    channel = "#test"
    message = event(%{text: "!list-minions", type: "message", channel: channel})
    assert channel_reply("[:minion@localhost, :medera@localhost]", channel) ==
      Handler.handle_event(message)
  end

  test "lists minion skills" do
    channel = "#test"
    message = event(
      %{
        text: "!list-skills medera@localhost",
        type: "message",
        channel: channel
      }
    )
    {:ok, {:reply, reply_text, ^channel}} =
      Handler.handle_event(message)
    assert reply_text =~ "%{"
  end

  test "requesting a command that does not exist" do
    message = event(%{text: "!killall-humans", type: "message"})
    assert {:error, "No matching command 'killall-humans'"} ==
      Handler.handle_event(message)
  end

  test "requesting a command without a required minion" do
    message = event(%{text: "!list-skills", type: "message"})
    assert {:error, "Must specify a node for 'list-skills'"} ==
      Handler.handle_event(message)
  end

  test "requesting a command on a node that cannot execute that command" do
    message = event(%{text: "!df-/ medera@localhost", type: "message"})
    assert {:error, "Invalid node for 'df-/'"} ==
      Handler.handle_event(message)
  end

  test "invoking a command on a particular node" do
    # remote node
    channel = "#test"
    message = event(
      %{
        text: "!get-minion-info minion@localhost",
        type: "message",
        channel: channel
      }
    )

    assert channel_reply("Hi, I am :minion@localhost.", channel) ==
      Handler.handle_event(message)

    # master node
    channel = "#test"
    message = event(
      %{
        text: "!get-minion-info medera@localhost",
        type: "message",
        channel: channel
      }
    )

    assert channel_reply("Hi, I am :medera@localhost.", channel) ==
      Handler.handle_event(message)
  end

  test "invoking a command that shells out" do
    # remote node
    channel = "#test"
    message = event(
      %{
        text: "!print-wd medera@localhost",
        type: "message",
        channel: channel
      }
    )

    project_dir = Path.expand("../../..", __DIR__)
    assert channel_reply(project_dir <> "\n", channel) ==
      Handler.handle_event(message)
  end
end
