defmodule Medera.Slack do
  defmodule State do
    @moduledoc false
    # internal state for slack adapter
    defstruct(connector: nil)
  end

  alias Medera.Slack.Event
  alias Medera.Slack.Handler

  def start_link(connector) do
    GenServer.start_link(__MODULE__, {connector}, name: __MODULE__)
  end

  def receive_event(event = %Event{}) do
    GenServer.call(__MODULE__, {:receive_event, event})
  end
  def receive_event(event = %{}) do
    receive_event(Event.from_slack(event))
  end

  def send_message(text, channel) do
    GenServer.call(__MODULE__, {:send_message, text, channel})
  end

  def init({connector}) do
    {:ok, %State{connector: connector}}
  end

  def handle_call({:receive_event, event}, _from, state) do
    :ok = Handler.handle_event(event)
    {:reply, :ok, state}
  end
  def handle_call({:send_message, text, channel}, _from, state) do
    send(state.connector, {:send_message, text, channel})
    {:reply, :ok, state}
  end
end
